import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { runOptionalChecks } from "./src/checks";
import { DEFAULT_MAX_SUGGESTIONS, STATUS_PREVIEW_CHARS } from "./src/constants";
import { collectGitContext } from "./src/git";
import { ensureGoalContext, resolveActiveGoal } from "./src/goal";
import { openFilePath } from "./src/open-file";
import { buildReviewPrompt } from "./src/review";
import { loadConfig, loadSession, saveSession } from "./src/storage";
import {
	extractSuggestedFiles,
	extractTextFromMessage,
	listProjectFiles,
	normalizeSuggestedFilesForProject,
} from "./src/suggestions";
import type { ConfigData, SuggestedFile } from "./src/types";
import { compactLines, previewText } from "./src/utils";

const CHAT_SUGGESTIONS_LIMIT = 3;
const SUGGESTION_PROMPT_FILE_LIMIT = 500;
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
	const seen = new Set<string>();
	for (const suggestion of suggestions) {
		if (!isActionableSuggestionPath(suggestion.path)) continue;
		if (seen.has(suggestion.path)) continue;
		seen.add(suggestion.path);
		filtered.push(suggestion);
	}
	return filtered;
}

function isReadTool(toolName: string): boolean {
	return toolName === "read" || toolName.endsWith(".read");
}

function buildSuggestionsChatBlock(suggestions: SuggestedFile[], limit = CHAT_SUGGESTIONS_LIMIT): string {
	const top = suggestions.slice(0, limit);
	return [
		"SASU suggested next files:",
		...top.map((s, i) => `${i + 1}. ${s.path}${s.reason ? ` — ${s.reason}` : ""}`),
		"",
		"(Run /sasu-open to browse or open other suggestions.)",
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
	candidateFiles: string[];
	maxSuggestions: number;
}): string {
	const changedLines = input.changedFiles.length
		? compactLines(input.changedFiles, 80).map((f) => `- ${f}`).join("\n")
		: "- (none)";
	const untrackedLines = input.untrackedFiles.length
		? compactLines(input.untrackedFiles, 80).map((f) => `- ${f}`).join("\n")
		: "- (none)";
	const candidateLines = input.candidateFiles.length
		? input.candidateFiles.slice(0, SUGGESTION_PROMPT_FILE_LIMIT).map((f) => `- ${f}`).join("\n")
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
		"Return a concise numbered list in plain text: <path> — <reason>.",
		"",
		"Rules:",
		`- Suggest at most ${input.maxSuggestions} files.`,
		"- Use ONLY paths from 'Candidate files'.",
		"- Prioritize files most relevant to the active focus and recent conversation intent.",
		"- Prefer implementation/source files over docs unless docs are explicitly requested.",
		"- Do not suggest .sasu/, .git/, node_modules/, dist/, or reference/ paths.",
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
		"Candidate files (absolute source of truth):",
		candidateLines,
	].join("\n");
}

async function showSuggestionsAndOfferOpen(input: {
	pi: ExtensionAPI;
	ctx: any;
	cwd: string;
	config: ConfigData;
	suggestions: SuggestedFile[];
}): Promise<void> {
	const suggestions = filterActionableSuggestions(input.suggestions);
	if (suggestions.length === 0) return;

	input.pi.sendMessage(
		{
			customType: "sasu-suggested-files",
			content: buildSuggestionsChatBlock(suggestions),
			display: true,
		},
		{ triggerTurn: false },
	);

	const topSuggestions = suggestions.slice(0, CHAT_SUGGESTIONS_LIMIT);
	if (!input.ctx.hasUI || topSuggestions.length === 0) return;

	const options = topSuggestions.map((s, i) => `${i + 1}. ${s.path}${s.reason ? ` — ${s.reason}` : ""}`);
	const skipOption = "Skip for now";
	const selected = await input.ctx.ui.select("SASU: open one suggested file now?", [...options, skipOption]);
	if (!selected || selected === skipOption) return;

	const selectedIndex = options.indexOf(selected);
	const selectedPath = topSuggestions[selectedIndex]?.path;
	if (!selectedPath) return;

	const opened = await openFilePath(input.cwd, selectedPath, input.config, input.ctx.ui);
	input.ctx.ui.notify(opened.message, opened.ok ? "info" : "error");
}

export default function sasu(pi: ExtensionAPI) {
	let awaitingReviewResponse = false;
	let skipNextReviewAgentEnd = false;
	let awaitingSuggestionResponse = false;
	let skipNextSuggestionAgentEnd = false;
	let suggestionGuardPreviousTools: string[] | null = null;

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
		const projectFiles = (await listProjectFiles(pi)).filter(isActionableSuggestionPath);
		if (projectFiles.length === 0) {
			input.ctx.ui.notify("No project files available for suggestion", "warning");
			return;
		}

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
			candidateFiles: projectFiles,
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
		description: "Open a file from cached SASU suggestions (with manual path fallback)",
		handler: async (_args, ctx) => {
			const cwd = ctx.cwd;
			const config = await loadConfig(cwd);
			const session = await loadSession(cwd);

			let suggestions = Array.isArray(session.lastSuggestedFiles) ? session.lastSuggestedFiles : [];
			suggestions = await normalizeSuggestedFilesForProject(
				pi,
				cwd,
				suggestions,
				config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS,
			);
			suggestions = filterActionableSuggestions(suggestions);

			if (suggestions.length === 0) {
				ctx.ui.notify("No cached suggestions. Run /sasu-suggest to get agent-based suggestions.", "warning");
				return;
			}

			await saveSession(cwd, {
				...session,
				lastSuggestedFiles: suggestions,
				lastSuggestionsUpdatedAt: new Date().toISOString(),
			});

			const options = suggestions.map((s, index) => {
				const reason = s.reason ? ` — ${s.reason}` : "";
				return `${index + 1}. ${s.path}${reason}`;
			});
			const manualOption = "✍ Enter path manually";
			const selected = await ctx.ui.select("SASU: choose a file to open", [...options, manualOption]);
			if (!selected) return;

			let targetPath: string | undefined;
			if (selected === manualOption) {
				targetPath = (await ctx.ui.input("File path", "src/..."))?.trim();
				if (!targetPath) return;
			} else {
				const matched = selected.match(/^(\d+)\.\s+/);
				if (matched) {
					const index = Number(matched[1]) - 1;
					targetPath = suggestions[index]?.path;
				}
			}

			if (!targetPath) {
				ctx.ui.notify("Could not resolve selected file path", "warning");
				return;
			}

			const opened = await openFilePath(cwd, targetPath, config, ctx.ui);
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
					ctx.ui.notify("SASU could not read suggestion response", "warning");
					return;
				}

				const config = await loadConfig(ctx.cwd);
				const session = await loadSession(ctx.cwd);
				let suggestions = extractSuggestedFiles(assistantText, config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS);
				suggestions = await normalizeSuggestedFilesForProject(
					pi,
					ctx.cwd,
					suggestions,
					config.maxSuggestions ?? DEFAULT_MAX_SUGGESTIONS,
				);
				suggestions = filterActionableSuggestions(suggestions);

				await saveSession(ctx.cwd, {
					...session,
					lastSuggestedFiles: suggestions,
					lastSuggestionsUpdatedAt: suggestions.length > 0 ? new Date().toISOString() : session.lastSuggestionsUpdatedAt,
				});

				if (suggestions.length === 0) {
					ctx.ui.notify("Agent returned no valid suggestions. Try /sasu-suggest with a clearer hint.", "warning");
					return;
				}

				await showSuggestionsAndOfferOpen({
					pi,
					ctx,
					cwd: ctx.cwd,
					config,
					suggestions,
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
