import { randomUUID } from "node:crypto";
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
import { buildMissionBrief, resolveIntentContext } from "./src/memory/brief";
import { ingestEvent, ingestEvents, type MemoryEventInput } from "./src/memory/ingest";
import { createMemoryStore } from "./src/memory/store";
import { loadConfig, loadSession, saveSession } from "./src/storage";
import {
	extractSuggestedFilesFromResponse,
	extractTextFromMessage,
	listProjectFiles,
	normalizeSuggestedFilesForProject,
} from "./src/suggestions";
import type { FeedbackAction, MemoryEventKind } from "./src/memory/types";
import type { CheckResult, ConfigData, GitContext, SuggestedFile } from "./src/types";
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
	action: "open" | "create";
	source: "project-file-index" | "sasu-suggest";
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
		if (candidate.action === "create") return 80;
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
	if (candidate.action === "create") score += 60;
	return score;
}

function rankOpenFileCandidates(candidates: OpenFileCandidate[], query: string): OpenFileCandidate[] {
	const ranked = candidates
		.map((candidate) => ({ candidate, score: scoreOpenFileCandidate(candidate, query) }))
		.filter((entry): entry is { candidate: OpenFileCandidate; score: number } => typeof entry.score === "number")
		.sort((a, b) => {
			if (b.score !== a.score) return b.score - a.score;
			if (a.candidate.action !== b.candidate.action) return a.candidate.action === "create" ? -1 : 1;
			if (a.candidate.suggested !== b.candidate.suggested) return a.candidate.suggested ? -1 : 1;
			return a.candidate.path.localeCompare(b.candidate.path);
		})
		.map((entry) => entry.candidate);
	return ranked.slice(0, OPEN_PICKER_MAX_RESULTS);
}

function toOpenFileSelectItems(candidates: OpenFileCandidate[]): SelectItem[] {
	return candidates.map((candidate) => {
		const prefix = candidate.action === "create" ? "✚ " : candidate.suggested ? "★ " : "";
		return {
			value: candidate.path,
			label: `${prefix}${candidate.path}`,
		};
	});
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
		const options = ranked.slice(0, 30).map((candidate, index) => {
			const prefix = candidate.action === "create" ? "[CREATE] " : candidate.suggested ? "[SUGGESTED] " : "";
			return `${index + 1}. ${prefix}${candidate.path}`;
		});
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

			const reason =
				candidate.reason?.trim() ||
				"No cached suggestion reason for this file. Open it directly when you already know where to go.";

			detailsTitle.setText(theme.fg("accent", theme.bold(` details: ${candidate.path}`)));
			detailsBody.setText(
				[
					theme.fg("dim", ` action: ${candidate.action}`),
					theme.fg("dim", ` source: ${candidate.source}`),
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

function parseReviewCommandArgs(rawArgs: string): { intent: string; showPrompt: boolean } {
	const showPrompt = /(?:^|\s)(?:--show-prompt|-p)(?=\s|$)/.test(rawArgs);
	const intent = rawArgs.replace(/(?:^|\s)(?:--show-prompt|-p)(?=\s|$)/g, " ").trim();
	return {
		intent,
		showPrompt,
	};
}

function buildReviewKickoffChatBlock(input: {
	projectGoalSource: string;
	projectGoal: string;
	activeFocusSource: string;
	activeFocus: string;
	intent: string;
	changedCount: number;
	untrackedCount: number;
	checkCount: number;
	checkPassCount: number;
	checkFailCount: number;
	queued: boolean;
	showPrompt: boolean;
}): string {
	const checkSummary =
		input.checkCount > 0
			? `${input.checkCount} total (${input.checkPassCount} pass, ${input.checkFailCount} fail)`
			: "none configured";

	return [
		input.queued ? "SASU review request queued" : "SASU review request sent",
		"",
		"Focus",
		`- Project goal source: ${input.projectGoalSource}`,
		`- Project goal: ${previewText(input.projectGoal, STATUS_PREVIEW_CHARS)}`,
		`- Active review focus source: ${input.activeFocusSource}`,
		`- Active review focus: ${previewText(input.activeFocus, STATUS_PREVIEW_CHARS)}`,
		"",
		"Scope",
		`- Changed files: ${input.changedCount}`,
		`- Untracked files: ${input.untrackedCount}`,
		`- Checks: ${checkSummary}`,
		"",
		`Intent: ${previewText(input.intent, 180)}`,
		`Dispatch: ${input.queued ? "follow-up turn" : "immediate turn"}`,
		input.showPrompt
			? "Prompt visibility: shown (--show-prompt)"
			: "Prompt visibility: hidden (default; use --show-prompt to debug)",
	].join("\n");
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
	onSuggestionAction?: (event: {
		action: FeedbackAction;
		suggestion?: SuggestedFile;
		context?: Record<string, unknown>;
	}) => Promise<void> | void;
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
	if (!input.ctx.hasUI || topSuggestions.length === 0) {
		await input.onSuggestionAction?.({
			action: "ignored",
			context: {
				reason: !input.ctx.hasUI ? "no_ui" : "no_top_suggestions",
				suggestionCount: suggestions.length,
			},
		});
		return;
	}

	const options = topSuggestions.map((suggestion, i) => `${i + 1}. ${formatSuggestionLabel(suggestion)}`);
	const skipOption = "Skip for now";
	const selected = await input.ctx.ui.select("SASU: open one suggested file now?", [...options, skipOption]);
	if (!selected || selected === skipOption) {
		await input.onSuggestionAction?.({
			action: "ignored",
			context: { reason: "skip", suggestionCount: topSuggestions.length },
		});
		return;
	}

	const selectedIndex = options.indexOf(selected);
	const selectedSuggestion = topSuggestions[selectedIndex];
	if (!selectedSuggestion?.path) {
		await input.onSuggestionAction?.({
			action: "dismissed",
			context: { reason: "invalid_selection", selected },
		});
		return;
	}

	if (selectedSuggestion.action === "create") {
		const createOption = "Create and open";
		const cancelOption = "Cancel";
		const confirmed = await input.ctx.ui.select(
			`SASU: create and open ${selectedSuggestion.path}?`,
			[createOption, cancelOption],
		);
		if (confirmed !== createOption) {
			await input.onSuggestionAction?.({
				action: "dismissed",
				suggestion: selectedSuggestion,
				context: { reason: "create_cancelled" },
			});
			return;
		}

		const created = await ensureSuggestedFileExists(input.cwd, selectedSuggestion.path);
		input.ctx.ui.notify(created.message, created.ok ? "info" : "error");
		if (!created.ok) {
			await input.onSuggestionAction?.({
				action: "dismissed",
				suggestion: selectedSuggestion,
				context: { reason: "create_failed", message: created.message },
			});
			return;
		}
	}

	const opened = await openFilePath(input.cwd, selectedSuggestion.path, input.config, input.ctx.ui);
	input.ctx.ui.notify(opened.message, opened.ok ? "info" : "error");
	await input.onSuggestionAction?.({
		action: opened.ok ? "accepted" : "dismissed",
		suggestion: selectedSuggestion,
		context: {
			reason: opened.ok ? "opened" : "open_failed",
			message: opened.message,
		},
	});
}

function buildMemoryStatusChatBlock(input: {
	dbPath: string;
	totalEvents: number;
	eventCounts: Record<string, number>;
	workingStateKeys: string[];
}): string {
	const countLines = Object.entries(input.eventCounts)
		.sort((a, b) => a[0].localeCompare(b[0]))
		.map(([kind, count]) => `- ${kind}: ${count}`);
	const stateLines = input.workingStateKeys.length > 0 ? input.workingStateKeys.map((key) => `- ${key}`) : ["- (none)"];
	return [
		"## SASU memory status",
		`DB: ${input.dbPath}`,
		`Total events: ${input.totalEvents}`,
		"",
		"Event counts by kind:",
		...(countLines.length > 0 ? countLines : ["- (none)"]),
		"",
		"Working state keys:",
		...stateLines,
	].join("\n");
}

function buildMemoryTailChatBlock(events: Array<{ id: string; ts: string; kind: string; source: string; payload: unknown }>): string {
	if (events.length === 0) {
		return ["## SASU memory tail", "(no events found)"] .join("\n");
	}

	const lines = events.map((event) => {
		const payloadLines = JSON.stringify(event.payload, null, 2).split(/\r?\n/);
		const payloadPreview = previewText(compactLines(payloadLines, 6).join(" "), 140);
		return `- ${event.ts} | ${event.kind} | ${event.source} | ${event.id}\n  payload: ${payloadPreview}`;
	});
	return ["## SASU memory tail", ...lines].join("\n");
}

function parseMemoryTailArgs(args: string): { limit: number; kind?: string } {
	const tokens = args
		.trim()
		.split(/\s+/)
		.filter((token) => token.length > 0);
	let limit = 20;
	let kind: string | undefined;
	for (let i = 0; i < tokens.length; i += 1) {
		const token = tokens[i];
		if ((token === "--kind" || token === "-k") && i + 1 < tokens.length) {
			kind = tokens[i + 1];
			i += 1;
			continue;
		}
		const asNumber = Number(token);
		if (Number.isFinite(asNumber) && asNumber > 0) {
			limit = Math.floor(asNumber);
		}
	}
	return { limit: Math.max(1, Math.min(limit, 200)), kind };
}

function shouldForceMemoryReset(args: string): boolean {
	return /(?:^|\s)--yes(?:\s|$)|(?:^|\s)-y(?:\s|$)/.test(args);
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

	const memoryStoreByCwd = new Map<string, Promise<Awaited<ReturnType<typeof createMemoryStore>>>>();
	const getMemoryStore = (cwd: string) => {
		const existing = memoryStoreByCwd.get(cwd);
		if (existing) return existing;
		const created = createMemoryStore(cwd);
		memoryStoreByCwd.set(cwd, created);
		return created;
	};

	const getSessionId = (ctx: any): string | undefined => {
		const raw = (ctx as any)?.sessionId;
		if (typeof raw !== "string") return undefined;
		const trimmed = raw.trim();
		return trimmed.length > 0 ? trimmed : undefined;
	};

	const emitMemoryEvent = async (
		ctx: any,
		event: Omit<MemoryEventInput, "projectRoot" | "sessionId">,
	): Promise<void> => {
		try {
			const store = await getMemoryStore(ctx.cwd);
			await ingestEvent(store, {
				...event,
				projectRoot: ctx.cwd,
				sessionId: getSessionId(ctx),
			});
		} catch {
			// memory ingestion is best-effort in v0
		}
	};

	const emitMemoryEvents = async (
		ctx: any,
		events: Array<Omit<MemoryEventInput, "projectRoot" | "sessionId">>,
	): Promise<void> => {
		if (events.length === 0) return;
		try {
			const store = await getMemoryStore(ctx.cwd);
			await ingestEvents(
				store,
				events.map((event) => ({
					...event,
					projectRoot: ctx.cwd,
					sessionId: getSessionId(ctx),
				})),
			);
		} catch {
			// memory ingestion is best-effort in v0
		}
	};

	const emitGitContextEvents = async (ctx: any, gitContext: GitContext, origin: string): Promise<void> => {
		const changedAreas = Array.from(new Set([...gitContext.changedFiles, ...gitContext.untrackedFiles]));
		const events: Array<Omit<MemoryEventInput, "projectRoot" | "sessionId">> = [
			{
				source: "git",
				kind: "code.git.snapshot",
				payload: {
					origin,
					available: gitContext.available,
					baseRef: gitContext.baseRef,
					note: gitContext.note,
					changedFiles: gitContext.changedFiles,
					untrackedFiles: gitContext.untrackedFiles,
					diffChars: gitContext.diff.length,
				},
			},
		];
		if (changedAreas.length > 0) {
			events.push({
				source: "git",
				kind: "code.files.changed",
				payload: {
					origin,
					files: changedAreas,
				},
			});
		}
		await emitMemoryEvents(ctx, events);
	};

	const emitCheckResultEvents = async (
		ctx: any,
		checks: CheckResult[],
		relatedFiles: string[],
		origin: string,
	): Promise<void> => {
		if (checks.length === 0) return;
		await emitMemoryEvents(
			ctx,
			checks.map((check) => ({
				source: "check",
				kind: "check.run.result" as const,
				payload: {
					origin,
					name: check.command,
					command: check.command,
					status: check.exitCode === 0 ? "pass" : "fail",
					exitCode: check.exitCode,
					files: relatedFiles,
					stdoutPreview: previewText(check.stdout, 200),
					stderrPreview: previewText(check.stderr, 200),
				},
			})),
		);
	};

	const resolveReviewMissionContext = async (input: {
		ctx: any;
		fallbackIntent: string;
		fallbackFocus: string;
		fallbackFocusSource: string;
	}): Promise<{
		resolvedIntentLabel: string;
		resolvedIntentSource: string;
		resolvedIntentConfidence?: number;
		needsClarification: boolean;
		activeFocus: string;
		activeFocusSource: string;
		missionBriefMarkdown?: string;
		memoryAvailable: boolean;
	}> => {
		const fallbackIntent = input.fallbackIntent.trim();
		let resolvedIntentLabel =
			fallbackIntent.length > 0 ? fallbackIntent : "No additional intent message provided.";
		let resolvedIntentSource = fallbackIntent.length > 0 ? "fallback.intent" : input.fallbackFocusSource;
		let resolvedIntentConfidence: number | undefined = undefined;
		let needsClarification = fallbackIntent.length === 0;
		let activeFocus = input.fallbackFocus;
		let activeFocusSource = input.fallbackFocusSource;
		let missionBriefMarkdown: string | undefined;

		try {
			const store = await getMemoryStore(input.ctx.cwd);
			const workingState = await store.getWorkingStateSnapshot();
			const resolvedIntent = resolveIntentContext({
				workingState,
				fallbackIntent: fallbackIntent.length > 0 ? fallbackIntent : input.fallbackFocus,
			});
			if (resolvedIntent.selected?.label?.trim()) {
				resolvedIntentLabel = resolvedIntent.selected.label;
				resolvedIntentSource = resolvedIntent.selected.source;
				resolvedIntentConfidence = resolvedIntent.selected.confidence;
				needsClarification = resolvedIntent.needsClarification;
			}

			const missionBrief = buildMissionBrief({
				workingState,
				fallbackIntent: fallbackIntent.length > 0 ? fallbackIntent : input.fallbackFocus,
			});
			missionBriefMarkdown = missionBrief.markdown;
			if (missionBrief.activeFocus?.trim()) {
				activeFocus = missionBrief.activeFocus;
				activeFocusSource = "memory.active_focus";
			}

			return {
				resolvedIntentLabel,
				resolvedIntentSource,
				resolvedIntentConfidence,
				needsClarification,
				activeFocus,
				activeFocusSource,
				missionBriefMarkdown,
				memoryAvailable: true,
			};
		} catch {
			return {
				resolvedIntentLabel,
				resolvedIntentSource,
				resolvedIntentConfidence,
				needsClarification,
				activeFocus,
				activeFocusSource,
				missionBriefMarkdown,
				memoryAvailable: false,
			};
		}
	};

	const recordSuggestionFeedback = async (
		ctx: any,
		input: {
			action: FeedbackAction;
			suggestion?: SuggestedFile;
			context?: Record<string, unknown>;
		},
	): Promise<void> => {
		const payload = {
			action: input.action,
			suggestionPath: input.suggestion?.path,
			suggestionAction: input.suggestion?.action ?? "open",
			...input.context,
		};
		await emitMemoryEvent(ctx, {
			source: "sasu",
			kind: "user.suggestion.action",
			payload,
		});
		try {
			const store = await getMemoryStore(ctx.cwd);
			await store.appendFeedback({
				id: randomUUID(),
				ts: new Date().toISOString(),
				suggestionId: input.suggestion?.path,
				action: input.action,
				context: payload,
			});
		} catch {
			// feedback persistence is best-effort in v0
		}
	};

	const requestAgentSuggestions = async (input: {
		ctx: any;
		cwd: string;
		config: ConfigData;
		hint?: string;
		origin: "sasu-suggest" | "sasu-goal";
	}) => {
		const session = await loadSession(input.cwd);
		const goalInfo = await ensureGoalContext(input.cwd, session, input.ctx);
		const gitContext = await collectGitContext(pi);
		await emitGitContextEvents(input.ctx, gitContext, `${input.origin}:suggest`);
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
		description: "Send current changes to Pi for a human-first review (use --show-prompt to debug prompt text)",
		handler: async (args, ctx) => {
			if (isBusyWaiting()) {
				ctx.ui.notify("SASU is already waiting for a response. Please wait for it to finish.", "warning");
				return;
			}

			const cwd = ctx.cwd;
			let session = await loadSession(cwd);
			const goalInfo = await ensureGoalContext(cwd, session, ctx);
			session = goalInfo.session;

			const parsedArgs = parseReviewCommandArgs(args);
			const explicitIntent = parsedArgs.intent.trim();
			await emitMemoryEvent(ctx, {
				source: "sasu",
				kind: "user.command.review",
				payload: {
					rawArgs: args,
					showPrompt: parsedArgs.showPrompt,
					intentProvided: explicitIntent.length > 0,
					activeFocus: goalInfo.activeGoal,
					activeFocusSource: goalInfo.activeGoalSource,
				},
			});
			if (explicitIntent.length > 0) {
				await emitMemoryEvent(ctx, {
					source: "pi",
					kind: "user.intent.explicit",
					payload: {
						intent: explicitIntent,
						command: "sasu-review",
					},
				});
			}

			const gitContext = await collectGitContext(pi);
			await emitGitContextEvents(ctx, gitContext, "sasu-review");
			const checks = await runOptionalChecks(pi, cwd);
			await emitCheckResultEvents(ctx, checks, gitContext.changedFiles, "sasu-review");
			const checkPassCount = checks.filter((check) => check.exitCode === 0).length;
			const checkFailCount = checks.length - checkPassCount;

			const fallbackIntent = explicitIntent || session.lastIntent?.trim() || goalInfo.activeGoal;
			const missionContext = await resolveReviewMissionContext({
				ctx,
				fallbackIntent,
				fallbackFocus: goalInfo.activeGoal,
				fallbackFocusSource: goalInfo.activeGoalSource,
			});
			const userIntent = explicitIntent || missionContext.resolvedIntentLabel || "No additional intent message provided.";
			const activeReviewFocus = missionContext.activeFocus?.trim() || goalInfo.activeGoal;
			const activeReviewFocusSource =
				missionContext.activeFocus?.trim().length && missionContext.activeFocusSource
					? missionContext.activeFocusSource
					: goalInfo.activeGoalSource;
			const resolvedIntentConfidence =
				missionContext.resolvedIntentConfidence ?? (explicitIntent.length > 0 ? 0.95 : 0.4);
			const resolvedIntentSource =
				explicitIntent.length > 0 ? "user.command.review" : missionContext.resolvedIntentSource;
			const intentNeedsClarification = explicitIntent.length > 0 ? false : missionContext.needsClarification;

			const reviewPrompt = buildReviewPrompt({
				projectGoal: goalInfo.projectGoal,
				projectGoalSource: goalInfo.projectGoalSource,
				sessionGoal: goalInfo.sessionGoal,
				sessionGoalSource: goalInfo.sessionGoalSource,
				activeGoal: activeReviewFocus,
				activeGoalSource: activeReviewFocusSource,
				intent: userIntent,
				intentContext: {
					label: userIntent,
					confidence: resolvedIntentConfidence,
					source: resolvedIntentSource,
					needsClarification: intentNeedsClarification,
				},
				missionBriefMarkdown: missionContext.missionBriefMarkdown,
				git: gitContext,
				checks,
			});

			session = {
				...session,
				lastIntent: explicitIntent || session.lastIntent,
			};
			await saveSession(cwd, session);

			const queued = !ctx.isIdle();
			pi.sendMessage(
				{
					customType: "sasu-review-start",
					content: buildReviewKickoffChatBlock({
						projectGoalSource: goalInfo.projectGoalSource,
						projectGoal: goalInfo.projectGoal,
						activeFocusSource: activeReviewFocusSource,
						activeFocus: activeReviewFocus,
						intent: userIntent,
						changedCount: gitContext.changedFiles.length,
						untrackedCount: gitContext.untrackedFiles.length,
						checkCount: checks.length,
						checkPassCount,
						checkFailCount,
						queued,
						showPrompt: parsedArgs.showPrompt,
					}),
					display: true,
				},
				{ triggerTurn: false },
			);

			awaitingReviewResponse = true;
			skipNextReviewAgentEnd = queued;

			if (parsedArgs.showPrompt) {
				if (queued) {
					pi.sendUserMessage(reviewPrompt, { deliverAs: "followUp" });
					await emitMemoryEvent(ctx, {
						source: "sasu",
						kind: "agent.review.requested",
						payload: {
							dispatchMode: "followUp",
							queued: true,
							showPrompt: true,
							checkCount: checks.length,
						},
					});
					ctx.ui.notify("SASU review queued as follow-up (prompt visible)", "info");
				} else {
					pi.sendUserMessage(reviewPrompt);
					await emitMemoryEvent(ctx, {
						source: "sasu",
						kind: "agent.review.requested",
						payload: {
							dispatchMode: "idle",
							queued: false,
							showPrompt: true,
							checkCount: checks.length,
						},
					});
					ctx.ui.notify("SASU review sent (prompt visible)", "info");
				}
				return;
			}

			if (queued) {
				pi.sendMessage(
					{
						customType: "sasu-review-request",
						content: reviewPrompt,
						display: false,
					},
					{ triggerTurn: true, deliverAs: "followUp" },
				);
				await emitMemoryEvent(ctx, {
					source: "sasu",
					kind: "agent.review.requested",
					payload: {
						dispatchMode: "followUp",
						queued: true,
						showPrompt: false,
						checkCount: checks.length,
					},
				});
				ctx.ui.notify("SASU review queued as follow-up", "info");
			} else {
				pi.sendMessage(
					{
						customType: "sasu-review-request",
						content: reviewPrompt,
						display: false,
					},
					{ triggerTurn: true },
				);
				await emitMemoryEvent(ctx, {
					source: "sasu",
					kind: "agent.review.requested",
					payload: {
						dispatchMode: "idle",
						queued: false,
						showPrompt: false,
						checkCount: checks.length,
					},
				});
				ctx.ui.notify("SASU review sent", "info");
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

	pi.registerCommand("sasu-memory-status", {
		description: "Show SASU memory DB status and working state summary",
		handler: async (_args, ctx) => {
			const store = await createMemoryStore(ctx.cwd);
			const totalEvents = await store.getEventTotalCount({ projectRoot: ctx.cwd });
			const eventCounts = await store.getEventCountsByKind({ projectRoot: ctx.cwd });
			const snapshot = await store.getWorkingStateSnapshot();
			const workingStateKeys = Object.keys(snapshot);
			pi.sendMessage(
				{
					customType: "sasu-memory-status",
					content: buildMemoryStatusChatBlock({
						dbPath: store.getDbPath(),
						totalEvents,
						eventCounts,
						workingStateKeys,
					}),
					display: true,
				},
				{ triggerTurn: false },
			);
		},
	});

	pi.registerCommand("sasu-memory-tail", {
		description: "Show latest SASU memory events (usage: /sasu-memory-tail [N] [--kind <kind>])",
		handler: async (args, ctx) => {
			const parsed = parseMemoryTailArgs(args);
			const store = await createMemoryStore(ctx.cwd);
			const events = await store.queryEvents({
				projectRoot: ctx.cwd,
				kinds: parsed.kind ? [parsed.kind as MemoryEventKind] : undefined,
				limit: parsed.limit,
			});
			pi.sendMessage(
				{
					customType: "sasu-memory-tail",
					content: buildMemoryTailChatBlock(events),
					display: true,
				},
				{ triggerTurn: false },
			);
		},
	});

	pi.registerCommand("sasu-memory-reset", {
		description: "Reset SASU memory DB for current project (use --yes to skip confirmation)",
		handler: async (args, ctx) => {
			const force = shouldForceMemoryReset(args);
			if (!force) {
				if (!ctx.hasUI) {
					ctx.ui.notify("Pass --yes to confirm memory reset in non-UI mode.", "warning");
					return;
				}
				const selected = await ctx.ui.select("Reset SASU memory for this project?", ["Reset", "Cancel"]);
				if (selected !== "Reset") {
					ctx.ui.notify("SASU memory reset cancelled", "warning");
					return;
				}
			}

			const store = await createMemoryStore(ctx.cwd);
			await store.resetAll();
			ctx.ui.notify("SASU memory reset complete", "info");
		},
	});

	pi.registerCommand("sasu-goal", {
		description: "Manage project goal + session focus, then ask for file suggestions",
		handler: async (args, ctx) => {
			if (isBusyWaiting()) {
				ctx.ui.notify("SASU is already waiting for a response. Please wait for it to finish.", "warning");
				return;
			}

			const cwd = ctx.cwd;
			const config = await loadConfig(cwd);
			let session = await loadSession(cwd);

			const requestedSessionFocus = args.trim();
			if (requestedSessionFocus.length > 0) {
				const goalInfo = await ensureGoalContext(cwd, session, ctx);
				session = goalInfo.session;

				await saveSession(cwd, {
					...session,
					sessionGoal: requestedSessionFocus,
					sessionGoalSource: "sasu-goal",
					sessionGoalUpdatedAt: new Date().toISOString(),
				});
				await emitMemoryEvents(ctx, [
					{
						source: "sasu",
						kind: "user.command.goal_set",
						payload: {
							rawArgs: args,
							projectGoal: session.projectGoal,
							sessionGoal: requestedSessionFocus,
							mode: "session",
						},
					},
					{
						source: "sasu",
						kind: "focus.override.manual",
						payload: {
							focus: requestedSessionFocus,
							locked: true,
							sourceCommand: "sasu-goal",
						},
					},
				]);
				ctx.ui.notify("SASU session focus set", "info");
				await requestAgentSuggestions({ ctx, cwd, config, origin: "sasu-goal" });
				return;
			}

			const goalInfo = await ensureGoalContext(cwd, session, ctx);
			session = goalInfo.session;

			const MODE_SESSION = "Update session focus";
			const MODE_PROJECT = "Update project goal";
			const MODE_BOTH = "Update both";
			const MODE_CANCEL = "Cancel";
			const mode = ctx.hasUI
				? await ctx.ui.select("SASU goals: what would you like to update?", [
						MODE_SESSION,
						MODE_PROJECT,
						MODE_BOTH,
						MODE_CANCEL,
				  ])
				: MODE_BOTH;
			if (!mode || mode === MODE_CANCEL) {
				ctx.ui.notify("SASU goals unchanged", "warning");
				return;
			}

			let next = session;
			let projectUpdated = false;
			let sessionUpdated = false;

			if (mode === MODE_PROJECT || mode === MODE_BOTH) {
				const enteredProjectGoal = (
					await ctx.ui.input(
						"SASU project goal (long-term)",
						next.projectGoal?.trim() || "What is the long-term goal of this project?",
					)
				)?.trim();
				if (enteredProjectGoal && enteredProjectGoal !== next.projectGoal) {
					next = {
						...next,
						projectGoal: enteredProjectGoal,
						projectGoalSource: "sasu-goal",
					};
					projectUpdated = true;
				}
			}

			if (mode === MODE_SESSION || mode === MODE_BOTH) {
				const enteredSessionFocus = (
					await ctx.ui.input(
						"SASU session focus (current loop)",
						next.sessionGoal?.trim() || next.projectGoal?.trim() || "What should this session focus on?",
					)
				)?.trim();
				if (enteredSessionFocus && enteredSessionFocus !== next.sessionGoal) {
					next = {
						...next,
						sessionGoal: enteredSessionFocus,
						sessionGoalSource: "sasu-goal",
						sessionGoalUpdatedAt: new Date().toISOString(),
					};
					sessionUpdated = true;
				}
			}

			if (!projectUpdated && !sessionUpdated) {
				ctx.ui.notify("SASU goals unchanged", "warning");
				return;
			}

			await saveSession(cwd, next);
			await emitMemoryEvent(ctx, {
				source: "sasu",
				kind: "user.command.goal_set",
				payload: {
					rawArgs: args,
					mode,
					projectUpdated,
					sessionUpdated,
					projectGoal: next.projectGoal,
					sessionGoal: next.sessionGoal,
				},
			});
			if (sessionUpdated && next.sessionGoal) {
				await emitMemoryEvent(ctx, {
					source: "sasu",
					kind: "focus.override.manual",
					payload: {
						focus: next.sessionGoal,
						locked: true,
						sourceCommand: "sasu-goal",
					},
				});
			}
			if (projectUpdated && sessionUpdated) {
				ctx.ui.notify("SASU project goal and session focus set", "info");
			} else if (projectUpdated) {
				ctx.ui.notify("SASU project goal set", "info");
			} else {
				ctx.ui.notify("SASU session focus set", "info");
			}
			await requestAgentSuggestions({ ctx, cwd, config, origin: "sasu-goal" });
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
			const hint = args.trim() || undefined;
			await emitMemoryEvent(ctx, {
				source: "sasu",
				kind: "user.command.suggest",
				payload: {
					rawArgs: args,
					hint,
				},
			});
			await requestAgentSuggestions({ ctx, cwd, config, hint, origin: "sasu-suggest" });
		},
	});

	pi.registerCommand("sasu-open", {
		description: "Open any project file with a fuzzy picker (optional initial filter)",
		handler: async (args, ctx) => {
			const cwd = ctx.cwd;
			const config = await loadConfig(cwd);
			const initialQuery = args.trim();

			const projectFiles = await listProjectFiles(pi, cwd);

			const session = await loadSession(cwd);
			let suggestions = Array.isArray(session.lastSuggestedFiles) ? session.lastSuggestedFiles : [];
			suggestions = await normalizeSuggestedFilesForProject(
				pi,
				cwd,
				suggestions,
				config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS,
			);
			suggestions = filterActionableSuggestions(suggestions);

			const openSuggestionReasonByPath = new Map<string, string | undefined>();
			const createSuggestions: SuggestedFile[] = [];
			for (const suggestion of suggestions) {
				const action = suggestion.action === "create" ? "create" : "open";
				if (action === "create") {
					createSuggestions.push(suggestion);
					continue;
				}
				if (!openSuggestionReasonByPath.has(suggestion.path)) {
					openSuggestionReasonByPath.set(suggestion.path, suggestion.reason);
				}
			}

			const candidateByPath = new Map<string, OpenFileCandidate>();
			for (const filePath of projectFiles) {
				const suggested = openSuggestionReasonByPath.has(filePath);
				candidateByPath.set(filePath, {
					path: filePath,
					baseName: path.posix.basename(filePath),
					action: "open",
					source: suggested ? "sasu-suggest" : "project-file-index",
					suggested,
					reason: openSuggestionReasonByPath.get(filePath),
				});
			}

			for (const suggestion of createSuggestions) {
				if (candidateByPath.has(suggestion.path)) continue;
				candidateByPath.set(suggestion.path, {
					path: suggestion.path,
					baseName: path.posix.basename(suggestion.path),
					action: "create",
					source: "sasu-suggest",
					suggested: true,
					reason: suggestion.reason,
				});
			}

			const candidates = Array.from(candidateByPath.values()).sort((a, b) => a.path.localeCompare(b.path));
			if (candidates.length === 0) {
				ctx.ui.notify("No files available to open or create.", "warning");
				return;
			}

			const selectedPath = await pickProjectFileWithFuzzyFilter({
				ctx,
				candidates,
				initialQuery,
			});
			if (!selectedPath) {
				if (suggestions.length > 0) {
					await recordSuggestionFeedback(ctx, {
						action: "ignored",
						context: { reason: "open_picker_cancelled", source: "sasu-open" },
					});
				}
				return;
			}

			const selectedCandidate = candidateByPath.get(selectedPath);
			if (suggestions.length > 0 && selectedCandidate && !selectedCandidate.suggested) {
				await recordSuggestionFeedback(ctx, {
					action: "edited",
					context: {
						reason: "selected_non_suggested_path",
						selectedPath,
						source: "sasu-open",
					},
				});
			}
			const selectedSuggestion: SuggestedFile | undefined = selectedCandidate?.suggested
				? {
						path: selectedPath,
						action: selectedCandidate.action,
						reason: selectedCandidate.reason,
				  }
				: undefined;

			if (selectedCandidate?.action === "create") {
				const createOption = "Create and open";
				const cancelOption = "Cancel";
				const confirmed = await ctx.ui.select(`SASU: create and open ${selectedPath}?`, [createOption, cancelOption]);
				if (confirmed !== createOption) {
					if (selectedSuggestion) {
						await recordSuggestionFeedback(ctx, {
							action: "dismissed",
							suggestion: selectedSuggestion,
							context: { reason: "create_cancelled", source: "sasu-open" },
						});
					}
					return;
				}

				const created = await ensureSuggestedFileExists(cwd, selectedPath);
				ctx.ui.notify(created.message, created.ok ? "info" : "error");
				if (!created.ok) {
					if (selectedSuggestion) {
						await recordSuggestionFeedback(ctx, {
							action: "dismissed",
							suggestion: selectedSuggestion,
							context: { reason: "create_failed", message: created.message, source: "sasu-open" },
						});
					}
					return;
				}
			}

			const opened = await openFilePath(cwd, selectedPath, config, ctx.ui);
			ctx.ui.notify(opened.message, opened.ok ? "info" : "error");
			if (selectedSuggestion) {
				await recordSuggestionFeedback(ctx, {
					action: opened.ok ? "accepted" : "dismissed",
					suggestion: selectedSuggestion,
					context: {
						reason: opened.ok ? "opened" : "open_failed",
						message: opened.message,
						source: "sasu-open",
					},
				});
			}
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
				await emitMemoryEvent(ctx, {
					source: "sasu",
					kind: "agent.suggestion.generated",
					payload: {
						suggestionCount: suggestions.length,
						suggestions: suggestions.map((suggestion) => ({
							path: suggestion.path,
							action: suggestion.action ?? "open",
							reason: suggestion.reason,
						})),
					},
				});

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
					onSuggestionAction: (actionEvent) => recordSuggestionFeedback(ctx, actionEvent),
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
		await emitMemoryEvent(ctx, {
			source: "sasu",
			kind: "agent.review.completed",
			payload: {
				summary: previewText(assistantText, 500),
				hasAssistantText: assistantText.length > 0,
				reviewedAt,
			},
		});

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
			onSuggestionAction: (actionEvent) => recordSuggestionFeedback(ctx, actionEvent),
		});
	});
}
