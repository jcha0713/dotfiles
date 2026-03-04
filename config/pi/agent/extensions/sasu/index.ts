import { access, mkdir, writeFile } from "node:fs/promises";
import * as path from "node:path";
import { DynamicBorder, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Key, SelectList, Text, matchesKey, type SelectItem } from "@mariozechner/pi-tui";
import { runOptionalChecks } from "./src/checks";
import { DEFAULT_MAX_SUGGESTIONS, STATUS_PREVIEW_CHARS } from "./src/constants";
import { collectGitContext } from "./src/git";
import { ensureGoalContext, resolveActiveGoal } from "./src/goal";
import { openFilePath } from "./src/open-file";
import { buildReviewPrompt } from "./src/review";
import { loadConfig, loadSession, saveSession } from "./src/storage";
import {
	extractSuggestedFilesFromResponse,
	extractTextFromMessage,
	listProjectFiles,
	normalizeSuggestedFilesForProject,
} from "./src/suggestions";
import type { ConfigData, SuggestedFile } from "./src/types";
import { compactLines, previewText } from "./src/utils";

const CHAT_SUGGESTIONS_LIMIT = 3;
const SUGGESTION_PROMPT_FILE_LIMIT = 500;
const OPEN_PICKER_VISIBLE_ROWS = 12;
const OPEN_PICKER_MAX_RESULTS = 200;
const NON_ACTIONABLE_SUGGESTION_PREFIXES = [".sasu/", ".git/", "node_modules/", "dist/", "reference/"];
const NON_ACTIONABLE_SUGGESTION_FILES = new Set([".sasu/session.json"]);

function isActionableSuggestionPath(filePath: string): boolean {
	const normalized = filePath.replace(/\\/g, "/").replace(/^\.\//, "");
	if (!normalized) return false;
	if (NON_ACTIONABLE_SUGGESTION_FILES.has(normalized)) return false;
	return NON_ACTIONABLE_SUGGESTION_PREFIXES.every((prefix) => !normalized.startsWith(prefix));
}

function filterActionableSuggestions(suggestions: SuggestedFile[]): SuggestedFile[] {
	const filtered: SuggestedFile[] = [];
	const indexByPath = new Map<string, number>();
	for (const suggestion of suggestions) {
		if (!isActionableSuggestionPath(suggestion.path)) continue;
		const action = suggestion.action === "create" ? "create" : "open";
		const existingIndex = indexByPath.get(suggestion.path);
		if (typeof existingIndex === "number") {
			const existing = filtered[existingIndex];
			if (existing.action === "create" && action === "open") {
				filtered[existingIndex] = { ...suggestion, action };
			}
			continue;
		}
		indexByPath.set(suggestion.path, filtered.length);
		filtered.push({ ...suggestion, action });
	}
	return filtered;
}

function isReadTool(toolName: string): boolean {
	return toolName === "read" || toolName.endsWith(".read");
}

function formatSuggestionLabel(suggestion: SuggestedFile): string {
	const actionPrefix = suggestion.action === "create" ? "[CREATE] " : "";
	const reason = suggestion.reason ? ` — ${suggestion.reason}` : "";
	return `${actionPrefix}${suggestion.path}${reason}`;
}

async function ensureSuggestedFileExists(cwd: string, filePath: string): Promise<{ ok: boolean; message: string }> {
	const resolvedPath = path.isAbsolute(filePath) ? filePath : path.join(cwd, filePath);
	const relativePath = path.relative(cwd, resolvedPath).replace(/\\/g, "/");
	if (!relativePath || relativePath === ".." || relativePath.startsWith("../") || path.isAbsolute(relativePath)) {
		return { ok: false, message: `Refusing to create file outside project root: ${filePath}` };
	}

	try {
		await access(resolvedPath);
		return { ok: true, message: `File already exists: ${relativePath}` };
	} catch {
		// Create the file below.
	}

	try {
		await mkdir(path.dirname(resolvedPath), { recursive: true });
		await writeFile(resolvedPath, "", { encoding: "utf8", flag: "wx" });
		return { ok: true, message: `Created: ${relativePath}` };
	} catch (error: any) {
		if (error?.code === "EEXIST") {
			return { ok: true, message: `File already exists: ${relativePath}` };
		}
		return {
			ok: false,
			message: `Failed to create ${relativePath}: ${error?.message || "unknown error"}`,
		};
	}
}

type OpenFileCandidate = {
	path: string;
	baseName: string;
	suggested: boolean;
	reason?: string;
};

function subsequenceScore(query: string, target: string): number | null {
	if (!query) return 0;
	let q = 0;
	let score = 0;
	let firstMatch = -1;
	let previousMatch = -1;

	for (let i = 0; i < target.length && q < query.length; i += 1) {
		if (target[i] !== query[q]) continue;
		if (firstMatch === -1) firstMatch = i;
		if (previousMatch === i - 1) {
			score += 7;
		} else {
			score += 3;
			if (previousMatch >= 0) score -= Math.min(4, i - previousMatch - 1);
		}
		previousMatch = i;
		q += 1;
	}

	if (q < query.length) return null;
	return score + Math.max(0, 20 - Math.max(0, firstMatch));
}

function scoreOpenFileCandidate(candidate: OpenFileCandidate, query: string): number | null {
	const trimmed = query.trim().toLowerCase();
	if (!trimmed) {
		return candidate.suggested ? 50 : 0;
	}

	const pathLower = candidate.path.toLowerCase();
	const baseLower = candidate.baseName.toLowerCase();
	let score = -1;

	const baseContains = baseLower.indexOf(trimmed);
	if (baseContains >= 0) {
		score = Math.max(score, 1000 - baseContains * 8 - baseLower.length);
	}

	const pathContains = pathLower.indexOf(trimmed);
	if (pathContains >= 0) {
		score = Math.max(score, 800 - pathContains * 2 - pathLower.length);
	}

	const baseSubsequence = subsequenceScore(trimmed, baseLower);
	if (baseSubsequence !== null) {
		score = Math.max(score, 600 + baseSubsequence);
	}

	const pathSubsequence = subsequenceScore(trimmed, pathLower);
	if (pathSubsequence !== null) {
		score = Math.max(score, 450 + pathSubsequence);
	}

	if (score < 0) return null;
	if (candidate.suggested) score += 90;
	return score;
}

function rankOpenFileCandidates(candidates: OpenFileCandidate[], query: string): OpenFileCandidate[] {
	const ranked = candidates
		.map((candidate) => ({ candidate, score: scoreOpenFileCandidate(candidate, query) }))
		.filter((entry): entry is { candidate: OpenFileCandidate; score: number } => typeof entry.score === "number")
		.sort((a, b) => {
			if (b.score !== a.score) return b.score - a.score;
			if (a.candidate.suggested !== b.candidate.suggested) return a.candidate.suggested ? -1 : 1;
			return a.candidate.path.localeCompare(b.candidate.path);
		})
		.map((entry) => entry.candidate);
	return ranked.slice(0, OPEN_PICKER_MAX_RESULTS);
}

function toOpenFileSelectItems(candidates: OpenFileCandidate[]): SelectItem[] {
	return candidates.map((candidate) => ({
		value: candidate.path,
		label: candidate.suggested ? `★ ${candidate.path}` : candidate.path,
	}));
}

async function pickProjectFileWithFuzzyFilter(input: {
	ctx: any;
	candidates: OpenFileCandidate[];
	initialQuery?: string;
}): Promise<string | null> {
	const initialQuery = input.initialQuery?.trim() || "";
	if (!input.ctx?.ui) return null;

	if (!input.ctx.ui?.custom) {
		const ranked = rankOpenFileCandidates(input.candidates, initialQuery);
		const options = ranked.slice(0, 30).map((candidate, index) => `${index + 1}. ${candidate.path}`);
		if (options.length === 0) return null;
		const selected = await input.ctx.ui.select("SASU: choose a project file", options);
		if (!selected) return null;
		const matched = selected.match(/^(\d+)\.\s+/);
		if (!matched) return null;
		const index = Number(matched[1]) - 1;
		return ranked[index]?.path ?? null;
	}

	const candidateByPath = new Map(input.candidates.map((candidate) => [candidate.path, candidate] as const));

	const selected = await input.ctx.ui.custom<string | null>((tui: any, theme: any, _kb: any, done: any) => {
		let filter = initialQuery;
		let ranked: OpenFileCandidate[] = [];
		let list: SelectList | null = null;

		const top = new DynamicBorder((s: string) => theme.fg("accent", s));
		const title = new Text(theme.fg("accent", theme.bold(" SASU open project file")), 0, 0);
		const filterLine = new Text("", 0, 0);
		const detailsDivider = new DynamicBorder((s: string) => theme.fg("dim", s));
		const detailsTitle = new Text("", 0, 0);
		const detailsBody = new Text("", 0, 0);
		const help = new Text(
			theme.fg(
				"dim",
				" ↑↓ navigate • type fuzzy filter • backspace delete • ctrl+u clear • enter open • esc cancel • details pane below",
			),
			0,
			0,
		);
		const bottom = new DynamicBorder((s: string) => theme.fg("accent", s));

		const selectTheme = {
			selectedPrefix: (text: string) => theme.fg("accent", text),
			selectedText: (text: string) => theme.fg("accent", text),
			description: (text: string) => theme.fg("muted", text),
			scrollInfo: (text: string) => theme.fg("dim", text),
			noMatch: (text: string) => theme.fg("warning", text),
		};

		const updateFilterLine = () => {
			const count = ranked.length;
			filterLine.setText(theme.fg("dim", ` filter: ${filter || "(empty)"} • matches: ${count}/${input.candidates.length}`));
		};

		const updateDetailsPane = (selectedPath?: string) => {
			const selectedValue =
				typeof selectedPath === "string" && selectedPath.length > 0
					? selectedPath
					: String(list?.getSelectedItem()?.value || "");
			if (!selectedValue) {
				detailsTitle.setText(theme.fg("dim", " details"));
				detailsBody.setText(theme.fg("dim", " Select a file to see full context."));
				return;
			}

			const candidate = candidateByPath.get(selectedValue);
			if (!candidate) {
				detailsTitle.setText(theme.fg("dim", " details"));
				detailsBody.setText(theme.fg("warning", " Selected file metadata is unavailable."));
				return;
			}

			const source = candidate.suggested ? "sasu-suggest" : "project-file-index";
			const reason =
				candidate.reason?.trim() ||
				"No cached suggestion reason for this file. Open it directly when you already know where to go.";

			detailsTitle.setText(theme.fg("accent", theme.bold(` details: ${candidate.path}`)));
			detailsBody.setText(
				[
					theme.fg("dim", ` source: ${source}`),
					theme.fg("dim", ` suggested: ${candidate.suggested ? "yes" : "no"}`),
					"",
					theme.fg("muted", " reason"),
					reason,
				].join("\n"),
			);
		};

		const buildList = () => {
			ranked = rankOpenFileCandidates(input.candidates, filter);
			updateFilterLine();
			const items = toOpenFileSelectItems(ranked);
			const nextList = new SelectList(items, Math.min(items.length || 1, OPEN_PICKER_VISIBLE_ROWS), selectTheme);
			nextList.onSelect = (item) => done(String(item.value));
			nextList.onCancel = () => done(null);
			nextList.onSelectionChange = (item) => {
				updateDetailsPane(String(item.value));
				tui.requestRender();
			};
			return nextList;
		};

		list = buildList();
		updateDetailsPane();

		return {
			render: (width: number) => [
				...top.render(width),
				...title.render(width),
				...filterLine.render(width),
				...(list ? list.render(width) : []),
				...detailsDivider.render(width),
				...detailsTitle.render(width),
				...detailsBody.render(width),
				...help.render(width),
				...bottom.render(width),
			],
			invalidate: () => {
				top.invalidate();
				title.invalidate();
				filterLine.invalidate();
				list?.invalidate();
				detailsDivider.invalidate();
				detailsTitle.invalidate();
				detailsBody.invalidate();
				help.invalidate();
				bottom.invalidate();
			},
			handleInput: (data: string) => {
				if (matchesKey(data, Key.backspace)) {
					filter = filter.slice(0, -1);
					list = buildList();
					updateDetailsPane();
					tui.requestRender();
					return;
				}
				if (matchesKey(data, Key.ctrl("u"))) {
					filter = "";
					list = buildList();
					updateDetailsPane();
					tui.requestRender();
					return;
				}
				if (data.length === 1 && data >= " " && data !== "\x7f") {
					filter += data;
					list = buildList();
					updateDetailsPane();
					tui.requestRender();
					return;
				}
				list?.handleInput(data);
				tui.requestRender();
			},
		};
	});

	return selected ?? null;
}

function buildSuggestionsChatBlock(suggestions: SuggestedFile[], limit = CHAT_SUGGESTIONS_LIMIT): string {
	const top = suggestions.slice(0, limit);
	return [
		"SASU suggested next files:",
		...top.map((s, i) => `${i + 1}. ${formatSuggestionLabel(s)}`),
		"",
		"(Suggestions are guidance. Run /sasu-open to fuzzy-open any project file.)",
	].join("\n");
}

function buildStatusChatBlock(input: {
	projectGoalSource: string;
	projectGoal: string;
	sessionFocusSource: string;
	sessionFocus: string;
	activeFocusSource: string;
	activeFocus: string;
	lastReview: string;
	suggestionCount: number;
	full: boolean;
}): string {
	const render = (value: string) => (input.full ? value : previewText(value, STATUS_PREVIEW_CHARS));
	const lines = [
		"SASU session status",
		"",
		"Goal context",
		`- Project goal source: ${input.projectGoalSource}`,
		`- Project goal (long-term): ${render(input.projectGoal)}`,
		`- Session focus source: ${input.sessionFocusSource}`,
		`- Session focus (current loop): ${render(input.sessionFocus)}`,
		`- Active review focus source: ${input.activeFocusSource}`,
		`- Active review focus: ${render(input.activeFocus)}`,
		"",
		"Metadata",
		`- Last review: ${input.lastReview}`,
		`- Cached suggestions: ${input.suggestionCount}`,
	];
	if (!input.full) lines.push("", "Hint: run /sasu-status --full for full goal text.");
	return lines.join("\n");
}

function buildSuggestionRequestPrompt(input: {
	projectGoal: string;
	projectGoalSource: string;
	sessionFocus?: string;
	sessionFocusSource?: string;
	activeFocus: string;
	activeFocusSource: string;
	hint?: string;
	lastIntent?: string;
	changedFiles: string[];
	untrackedFiles: string[];
	candidatePaths: string[];
	maxSuggestions: number;
}): string {
	const changedLines = input.changedFiles.length
		? compactLines(input.changedFiles, 80).map((f) => `- ${f}`).join("\n")
		: "- (none)";
	const untrackedLines = input.untrackedFiles.length
		? compactLines(input.untrackedFiles, 80).map((f) => `- ${f}`).join("\n")
		: "- (none)";
	const candidateLines = input.candidatePaths.length
		? input.candidatePaths.slice(0, SUGGESTION_PROMPT_FILE_LIMIT).map((candidatePath) => `- ${candidatePath}`).join("\n")
		: "- (no files found)";

	return [
		"SASU file suggestion request",
		"",
		"You are in confident suggestion mode.",
		"You may use the read tool to inspect candidate files before suggesting where to start.",
		"Do NOT make or propose code edits.",
		"Do NOT call tools other than read.",
		"Use concrete evidence from inspected files (functions/sections) in each reason.",
		"Avoid hedging words like likely, may, might, or potentially.",
		"Return a concise numbered list in plain text. Each line must start with OPEN or CREATE:",
		"- OPEN <existing-path> — <reason>",
		"- CREATE <new-path> — <reason>",
		"",
		"Rules:",
		`- Suggest at most ${input.maxSuggestions} files.`,
		"- OPEN paths must come ONLY from 'Candidate files'.",
		"- CREATE paths must be project-relative file paths for new files.",
		"- Prioritize files most relevant to the active focus and recent conversation intent.",
		"- Prefer implementation/source files over docs unless docs are explicitly requested.",
		"- Do not suggest .sasu/, .git/, node_modules/, dist/, or reference/ paths.",
		"- If read returns ENOENT for a path, do not suggest it with OPEN.",
		"- Use CREATE only when explicitly recommending a new file.",
		"- Keep each reason concise.",
		"",
		"Goal context:",
		`- Project goal source: ${input.projectGoalSource}`,
		`- Project goal: ${input.projectGoal}`,
		`- Session focus source: ${input.sessionFocus ? input.sessionFocusSource ?? "session-goal" : "(not set)"}`,
		`- Session focus: ${input.sessionFocus ?? "(not set)"}`,
		`- Active review focus source: ${input.activeFocusSource}`,
		`- Active review focus: ${input.activeFocus}`,
		`- Optional hint: ${input.hint?.trim() || "(none)"}`,
		`- Last review intent: ${input.lastIntent?.trim() || "(none)"}`,
		"",
		"Recently changed files:",
		changedLines,
		"",
		"Recently untracked files:",
		untrackedLines,
		"",
		"Candidate files for OPEN (absolute source of truth):",
		candidateLines,
	].join("\n");
}

async function showSuggestionsAndOfferOpen(input: {
	pi: ExtensionAPI;
	ctx: any;
	cwd: string;
	config: ConfigData;
	suggestions: SuggestedFile[];
	showChatBlock?: boolean;
}): Promise<void> {
	const suggestions = filterActionableSuggestions(input.suggestions);
	if (suggestions.length === 0) return;

	if (input.showChatBlock !== false) {
		input.pi.sendMessage(
			{
				customType: "sasu-suggested-files",
				content: buildSuggestionsChatBlock(suggestions),
				display: true,
			},
			{ triggerTurn: false },
		);
	}

	const topSuggestions = suggestions.slice(0, CHAT_SUGGESTIONS_LIMIT);
	if (!input.ctx.hasUI || topSuggestions.length === 0) return;

	const options = topSuggestions.map((suggestion, i) => `${i + 1}. ${formatSuggestionLabel(suggestion)}`);
	const skipOption = "Skip for now";
	const selected = await input.ctx.ui.select("SASU: open one suggested file now?", [...options, skipOption]);
	if (!selected || selected === skipOption) return;

	const selectedIndex = options.indexOf(selected);
	const selectedSuggestion = topSuggestions[selectedIndex];
	if (!selectedSuggestion?.path) return;

	if (selectedSuggestion.action === "create") {
		const createOption = "Create and open";
		const cancelOption = "Cancel";
		const confirmed = await input.ctx.ui.select(
			`SASU: create and open ${selectedSuggestion.path}?`,
			[createOption, cancelOption],
		);
		if (confirmed !== createOption) return;

		const created = await ensureSuggestedFileExists(input.cwd, selectedSuggestion.path);
		input.ctx.ui.notify(created.message, created.ok ? "info" : "error");
		if (!created.ok) return;
	}

	const opened = await openFilePath(input.cwd, selectedSuggestion.path, input.config, input.ctx.ui);
	input.ctx.ui.notify(opened.message, opened.ok ? "info" : "error");
}

export default function sasu(pi: ExtensionAPI) {
	let awaitingReviewResponse = false;
	let skipNextReviewAgentEnd = false;
	let awaitingSuggestionResponse = false;
	let skipNextSuggestionAgentEnd = false;
	let suggestionGuardPreviousTools: string[] | null = null;
	let pendingSuggestionPaths: string[] | null = null;

	const isBusyWaiting = () => awaitingReviewResponse || awaitingSuggestionResponse;
	const enterSuggestionGuard = (): boolean => {
		if (suggestionGuardPreviousTools !== null) {
			return suggestionGuardPreviousTools.some((tool) => isReadTool(tool));
		}
		suggestionGuardPreviousTools = pi.getActiveTools();
		const readOnlyTools = suggestionGuardPreviousTools.filter((tool) => isReadTool(tool));
		pi.setActiveTools(readOnlyTools);
		return readOnlyTools.length > 0;
	};
	const exitSuggestionGuard = () => {
		if (suggestionGuardPreviousTools === null) return;
		pi.setActiveTools(suggestionGuardPreviousTools);
		suggestionGuardPreviousTools = null;
	};

	const requestAgentSuggestions = async (input: {
		ctx: any;
		cwd: string;
		config: ConfigData;
		hint?: string;
	}) => {
		const session = await loadSession(input.cwd);
		const goalInfo = await ensureGoalContext(input.cwd, session, input.ctx);
		const gitContext = await collectGitContext(pi);
		const candidatePaths = (await listProjectFiles(pi, input.cwd)).filter(isActionableSuggestionPath);
		if (candidatePaths.length === 0) {
			input.ctx.ui.notify("No project files available for suggestion", "warning");
			return;
		}

		pendingSuggestionPaths = candidatePaths;

		const prompt = buildSuggestionRequestPrompt({
			projectGoal: goalInfo.projectGoal,
			projectGoalSource: goalInfo.projectGoalSource,
			sessionFocus: goalInfo.sessionGoal,
			sessionFocusSource: goalInfo.sessionGoalSource,
			activeFocus: goalInfo.activeGoal,
			activeFocusSource: goalInfo.activeGoalSource,
			hint: input.hint,
			lastIntent: session.lastIntent,
			changedFiles: gitContext.changedFiles,
			untrackedFiles: gitContext.untrackedFiles,
			candidatePaths,
			maxSuggestions: input.config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS,
		});

		if (input.ctx.isIdle()) {
			const hasReadTool = enterSuggestionGuard();
			if (!hasReadTool) {
				input.ctx.ui.notify("SASU suggestion guard enabled with no read tool available (all tools disabled)", "warning");
			}
			awaitingSuggestionResponse = true;
			skipNextSuggestionAgentEnd = false;
			try {
				pi.sendMessage(
					{
						customType: "sasu-suggestion-request",
						content: prompt,
						display: false,
					},
					{ triggerTurn: true, deliverAs: "steer" },
				);
				input.ctx.ui.notify("SASU requested agent-based file suggestions", "info");
			} catch {
				awaitingSuggestionResponse = false;
				pendingSuggestionPaths = null;
				exitSuggestionGuard();
				input.ctx.ui.notify("Failed to request agent-based file suggestions", "error");
				return;
			}
		} else {
			const hasReadTool = enterSuggestionGuard();
			if (!hasReadTool) {
				input.ctx.ui.notify("SASU suggestion guard enabled with no read tool available (all tools disabled)", "warning");
			}
			awaitingSuggestionResponse = true;
			skipNextSuggestionAgentEnd = true;
			try {
				pi.sendMessage(
					{
						customType: "sasu-suggestion-request",
						content: prompt,
						display: false,
					},
					{ triggerTurn: true, deliverAs: "followUp" },
				);
				input.ctx.ui.notify("SASU queued agent-based file suggestions", "info");
			} catch {
				awaitingSuggestionResponse = false;
				pendingSuggestionPaths = null;
				exitSuggestionGuard();
				input.ctx.ui.notify("Failed to queue agent-based file suggestions", "error");
				return;
			}
		}
	};

	pi.registerCommand("sasu-review", {
		description: "Send current changes to Pi for a human-first review",
		handler: async (args, ctx) => {
			if (isBusyWaiting()) {
				ctx.ui.notify("SASU is already waiting for a response. Please wait for it to finish.", "warning");
				return;
			}

			const cwd = ctx.cwd;
			let session = await loadSession(cwd);
			const goalInfo = await ensureGoalContext(cwd, session, ctx);
			session = goalInfo.session;

			const userIntent = args.trim().length > 0 ? args.trim() : "No additional intent message provided.";
			const gitContext = await collectGitContext(pi);
			const checks = await runOptionalChecks(pi, cwd);

			const reviewPrompt = buildReviewPrompt({
				projectGoal: goalInfo.projectGoal,
				projectGoalSource: goalInfo.projectGoalSource,
				sessionGoal: goalInfo.sessionGoal,
				sessionGoalSource: goalInfo.sessionGoalSource,
				activeGoal: goalInfo.activeGoal,
				activeGoalSource: goalInfo.activeGoalSource,
				intent: userIntent,
				git: gitContext,
				checks,
			});

			session = {
				...session,
				lastIntent: args.trim() || session.lastIntent,
			};
			await saveSession(cwd, session);

			if (ctx.isIdle()) {
				awaitingReviewResponse = true;
				skipNextReviewAgentEnd = false;
				pi.sendUserMessage(reviewPrompt);
				ctx.ui.notify("SASU review sent", "info");
			} else {
				awaitingReviewResponse = true;
				skipNextReviewAgentEnd = true;
				pi.sendUserMessage(reviewPrompt, { deliverAs: "followUp" });
				ctx.ui.notify("SASU review queued as follow-up", "info");
			}
		},
	});

	pi.registerCommand("sasu-status", {
		description: "Show current SASU session context",
		handler: async (args, ctx) => {
			const session = await loadSession(ctx.cwd);
			const full = /(?:^|\s)--full(?:\s|$)|(?:^|\s)-f(?:\s|$)/.test(args);
			const projectGoal = session.projectGoal?.trim() || "(not set)";
			const projectGoalSource = session.projectGoalSource ?? "(unknown)";
			const sessionGoal = session.sessionGoal?.trim() || "(not set)";
			const sessionGoalSource = session.sessionGoal?.trim()
				? session.sessionGoalSource ?? "session-goal"
				: "(not set)";
			const active = resolveActiveGoal(session);
			const activeGoal = active?.goal ?? "(not set)";
			const activeGoalSource = active?.source ?? "(not set)";
			const lastReview = session.lastReviewAt ?? "(none yet)";
			const suggestionCount = filterActionableSuggestions(
				Array.isArray(session.lastSuggestedFiles) ? session.lastSuggestedFiles : [],
			).length;

			pi.sendMessage(
				{
					customType: "sasu-status",
					content: buildStatusChatBlock({
						projectGoalSource,
						projectGoal,
						sessionFocusSource: sessionGoalSource,
						sessionFocus: sessionGoal,
						activeFocusSource: activeGoalSource,
						activeFocus: activeGoal,
						lastReview,
						suggestionCount,
						full,
					}),
					display: true,
				},
				{ triggerTurn: false },
			);
		},
	});

	pi.registerCommand("sasu-goal", {
		description: "Set the current session focus and ask the agent for file suggestions",
		handler: async (args, ctx) => {
			if (isBusyWaiting()) {
				ctx.ui.notify("SASU is already waiting for a response. Please wait for it to finish.", "warning");
				return;
			}

			const cwd = ctx.cwd;
			const config = await loadConfig(cwd);
			const session = await loadSession(cwd);

			const requestedGoal = args.trim();
			const enteredGoal = requestedGoal.length
				? requestedGoal
				: (await ctx.ui.input(
						"SASU session focus",
						session.sessionGoal?.trim() || session.projectGoal?.trim() || "What should this session focus on?",
				  ))?.trim() || "";
			if (!enteredGoal) {
				ctx.ui.notify("SASU session focus unchanged", "warning");
				return;
			}

			await saveSession(cwd, {
				...session,
				sessionGoal: enteredGoal,
				sessionGoalSource: "sasu-goal",
				sessionGoalUpdatedAt: new Date().toISOString(),
			});

			ctx.ui.notify("SASU session focus set", "info");
			await requestAgentSuggestions({ ctx, cwd, config });
		},
	});

	pi.registerCommand("sasu-suggest", {
		description: "Ask the agent for file suggestions based on active focus + session chat",
		handler: async (args, ctx) => {
			if (isBusyWaiting()) {
				ctx.ui.notify("SASU is already waiting for a response. Please wait for it to finish.", "warning");
				return;
			}
			const cwd = ctx.cwd;
			const config = await loadConfig(cwd);
			await requestAgentSuggestions({ ctx, cwd, config, hint: args.trim() || undefined });
		},
	});

	pi.registerCommand("sasu-open", {
		description: "Open any project file with a fuzzy picker (optional initial filter)",
		handler: async (args, ctx) => {
			const cwd = ctx.cwd;
			const config = await loadConfig(cwd);
			const initialQuery = args.trim();

			const projectFiles = await listProjectFiles(pi, cwd);
			if (projectFiles.length === 0) {
				ctx.ui.notify("No project files available to open.", "warning");
				return;
			}

			const session = await loadSession(cwd);
			let suggestions = Array.isArray(session.lastSuggestedFiles) ? session.lastSuggestedFiles : [];
			suggestions = await normalizeSuggestedFilesForProject(
				pi,
				cwd,
				suggestions,
				config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS,
			);
			suggestions = filterActionableSuggestions(suggestions);

			const suggestionReasonByPath = new Map<string, string | undefined>();
			for (const suggestion of suggestions) {
				if ((suggestion.action ?? "open") !== "open") continue;
				if (!suggestionReasonByPath.has(suggestion.path)) {
					suggestionReasonByPath.set(suggestion.path, suggestion.reason);
				}
			}

			const candidates: OpenFileCandidate[] = projectFiles
				.map((filePath) => ({
					path: filePath,
					baseName: path.posix.basename(filePath),
					suggested: suggestionReasonByPath.has(filePath),
					reason: suggestionReasonByPath.get(filePath),
				}))
				.sort((a, b) => a.path.localeCompare(b.path));

			const selectedPath = await pickProjectFileWithFuzzyFilter({
				ctx,
				candidates,
				initialQuery,
			});
			if (!selectedPath) return;

			const opened = await openFilePath(cwd, selectedPath, config, ctx.ui);
			ctx.ui.notify(opened.message, opened.ok ? "info" : "error");
		},
	});

	pi.on("agent_end", async (event: any, ctx) => {
		const messages = Array.isArray(event?.messages) ? event.messages : [];
		if (messages.length === 0) return;

		const lastAssistant = [...messages].reverse().find((msg: any) => msg?.role === "assistant");
		if (!lastAssistant) return;
		const assistantText = extractTextFromMessage(lastAssistant).trim();

		if (awaitingSuggestionResponse) {
			if (skipNextSuggestionAgentEnd) {
				skipNextSuggestionAgentEnd = false;
				return;
			}
			awaitingSuggestionResponse = false;

			try {
				if (!assistantText) {
					pendingSuggestionPaths = null;
					ctx.ui.notify("SASU could not read suggestion response", "warning");
					return;
				}

				const config = await loadConfig(ctx.cwd);
				const session = await loadSession(ctx.cwd);
				const maxSuggestions = config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS;
				const candidatePaths = pendingSuggestionPaths;
				pendingSuggestionPaths = null;

				if (!candidatePaths || candidatePaths.length === 0) {
					ctx.ui.notify("SASU suggestion context expired. Run /sasu-suggest again.", "warning");
					return;
				}

				let suggestions = extractSuggestedFilesFromResponse(assistantText, candidatePaths, maxSuggestions);
				suggestions = await normalizeSuggestedFilesForProject(pi, ctx.cwd, suggestions, maxSuggestions);
				suggestions = filterActionableSuggestions(suggestions);

				await saveSession(ctx.cwd, {
					...session,
					lastSuggestedFiles: suggestions,
					lastSuggestionsUpdatedAt: suggestions.length > 0 ? new Date().toISOString() : session.lastSuggestionsUpdatedAt,
				});

				if (suggestions.length === 0) {
					ctx.ui.notify("Agent returned no valid OPEN/CREATE suggestions. Try /sasu-suggest again.", "warning");
					return;
				}

				await showSuggestionsAndOfferOpen({
					pi,
					ctx,
					cwd: ctx.cwd,
					config,
					suggestions,
					showChatBlock: false,
				});
				return;
			} finally {
				exitSuggestionGuard();
			}
		}

		if (!awaitingReviewResponse) return;
		if (skipNextReviewAgentEnd) {
			skipNextReviewAgentEnd = false;
			return;
		}
		awaitingReviewResponse = false;

		const session = await loadSession(ctx.cwd);
		const config = await loadConfig(ctx.cwd);
		const reviewedAt = new Date().toISOString();

		let suggestions = Array.isArray(session.lastSuggestedFiles) ? session.lastSuggestedFiles : [];
		suggestions = await normalizeSuggestedFilesForProject(
			pi,
			ctx.cwd,
			suggestions,
			config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS,
		);
		suggestions = filterActionableSuggestions(suggestions);

		if (suggestions.length === 0) {
			await saveSession(ctx.cwd, {
				...session,
				lastReviewAt: reviewedAt,
			});
			ctx.ui.notify("No cached suggestions. Run /sasu-suggest for agent-based file suggestions.", "info");
			return;
		}

		await saveSession(ctx.cwd, {
			...session,
			lastReviewAt: reviewedAt,
			lastSuggestedFiles: suggestions,
			lastSuggestionsUpdatedAt: new Date().toISOString(),
		});

		await showSuggestionsAndOfferOpen({
			pi,
			ctx,
			cwd: ctx.cwd,
			config,
			suggestions,
		});
	});
}
