import { MAX_FINAL_PROMPT_CHARS } from "./constants";
import type { CheckResult, GitContext } from "./types";
import { compactLines, truncateText } from "./utils";

export function buildReviewPrompt(input: {
	projectGoal: string;
	projectGoalSource: string;
	sessionGoal?: string;
	sessionGoalSource?: string;
	activeGoal: string;
	activeGoalSource: string;
	intent: string;
	git: GitContext;
	checks: CheckResult[];
	missionBriefMarkdown?: string;
	intentContext?: {
		label: string;
		confidence: number;
		source: string;
		needsClarification: boolean;
	};
}): string {
	const changedLines = input.git.changedFiles.length
		? compactLines(input.git.changedFiles, 200).map((f) => `- ${f}`).join("\n")
		: "- (no tracked file changes detected)";

	const untrackedLines = input.git.untrackedFiles.length
		? compactLines(input.git.untrackedFiles, 200).map((f) => `- ${f}`).join("\n")
		: "- (none)";

	const checksBlock =
		input.checks.length === 0
			? "No checks configured (this is okay for now)."
			: input.checks
					.map((check) => {
						const status = check.exitCode === 0 ? "PASS" : "FAIL";
						const stdout = check.stdout.trim().length > 0 ? check.stdout.trim() : "(empty)";
						const stderr = check.stderr.trim().length > 0 ? check.stderr.trim() : "(empty)";
						return [
							`### ${check.command}`,
							`Result: ${status} (exit ${check.exitCode})`,
							"stdout:",
							"```text",
							stdout,
							"```",
							"stderr:",
							"```text",
							stderr,
							"```",
						].join("\n");
					})
					.join("\n\n");

	const diffBlock = input.git.available
		? input.git.diff.trim().length > 0
			? ["```diff", input.git.diff.trim(), "```"].join("\n")
			: "(No tracked diff content found.)"
		: input.git.note ?? "Git data unavailable.";

	const missionBriefBlock = input.missionBriefMarkdown?.trim().length
		? input.missionBriefMarkdown.trim()
		: "## SASU Mission Brief\n(unavailable; using direct goal/check/git context fallback)";
	const intentContextLines = input.intentContext
		? [
				`Memory-selected intent: ${input.intentContext.label} (${input.intentContext.confidence.toFixed(2)} via ${input.intentContext.source})`,
				`Needs clarification: ${input.intentContext.needsClarification ? "yes" : "no"}`,
		  ]
		: ["Memory-selected intent: (unavailable)"];

	const prompt = [
		"SASU review request",
		"",
		"You are reviewing code in a human-first workflow.",
		"The user wrote the code; your role is to validate and guide, not take over implementation.",
		"Default to coach-only behavior: do not offer to implement code, write patches, or take over unless the user explicitly requests implementation.",
		"",
		missionBriefBlock,
		"",
		"## Goal context",
		`Project goal source: ${input.projectGoalSource}`,
		`Project goal: ${input.projectGoal}`,
		`Session focus source: ${input.sessionGoal ? input.sessionGoalSource ?? "session-goal" : "(not set)"}`,
		`Session focus: ${input.sessionGoal ?? "(not set; fallback to project goal)"}`,
		`Active review focus source: ${input.activeGoalSource}`,
		`Active review focus: ${input.activeGoal}`,
		"",
		"## User intent for this review",
		input.intent,
		...intentContextLines,
		"",
		"## Changed files",
		changedLines,
		"",
		"## Untracked files",
		untrackedLines,
		"",
		"## Diff",
		diffBlock,
		"",
		"## Error/check state",
		checksBlock,
		"",
		"Please respond with:",
		"1) Intent understanding (did the changes match intent?)",
		"2) Change summary",
		"3) Issues/risks by severity",
		"4) Concrete next steps (what to edit/debug, where to look)",
		"Do NOT include a suggested-files section in normal text. SASU renders the sasu-suggested-files block separately.",
	].join("\n");

	return truncateText(prompt, MAX_FINAL_PROMPT_CHARS).text;
}
