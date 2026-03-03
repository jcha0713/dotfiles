import { access, readFile } from "node:fs/promises";
import * as path from "node:path";
import { GOAL_CANDIDATE_FILES, MAX_GOAL_CHARS } from "./constants";
import { saveSession } from "./storage";
import type { Nullable, SessionData } from "./types";
import { truncateText } from "./utils";

function normalizeGoalSnippet(text: string): string {
	const normalized = text
		.replace(/```[\s\S]*?```/g, "")
		.split("\n")
		.map((line) => line.trim())
		.filter((line) => line.length > 0)
		.map((line) => line.replace(/^[-*]\s+/, ""))
		.join(" ")
		.replace(/\s+/g, " ")
		.trim();

	return truncateText(normalized, MAX_GOAL_CHARS).text;
}

function extractGoalFromMarkdown(content: string): Nullable<string> {
	const headingRegexes = [
		/^##\s*Goal\b[^\n]*\n([\s\S]*?)(?=^##\s|^#\s|(?![\s\S]))/im,
		/^##\s*Vision\b[^\n]*\n([\s\S]*?)(?=^##\s|^#\s|(?![\s\S]))/im,
		/^##\s*Objective\b[^\n]*\n([\s\S]*?)(?=^##\s|^#\s|(?![\s\S]))/im,
	];

	for (const regex of headingRegexes) {
		const match = content.match(regex);
		if (match?.[1]) {
			const snippet = normalizeGoalSnippet(match[1]);
			if (snippet.length > 0) return snippet;
		}
	}

	const paragraphs = content
		.split(/\n\s*\n/g)
		.map((p) => p.trim())
		.filter((p) => p.length > 0 && !p.startsWith("#") && !p.startsWith("```"));

	for (const paragraph of paragraphs) {
		const snippet = normalizeGoalSnippet(paragraph);
		if (snippet.length >= 20) return snippet;
	}

	return null;
}

async function fileExists(filePath: string): Promise<boolean> {
	try {
		await access(filePath);
		return true;
	} catch {
		return false;
	}
}

async function detectProjectGoal(cwd: string): Promise<Nullable<{ goal: string; source: string }>> {
	for (const candidate of GOAL_CANDIDATE_FILES) {
		const fullPath = path.join(cwd, candidate);
		if (!(await fileExists(fullPath))) continue;
		try {
			const content = await readFile(fullPath, "utf8");
			const extracted = extractGoalFromMarkdown(content);
			if (extracted) return { goal: extracted, source: candidate };
		} catch {
			// ignore read errors and continue with next candidate
		}
	}
	return null;
}

export function resolveActiveGoal(session: SessionData): Nullable<{ goal: string; source: string }> {
	if (session.sessionGoal?.trim()) {
		return {
			goal: session.sessionGoal,
			source: session.sessionGoalSource ?? "session-goal",
		};
	}
	if (session.projectGoal?.trim()) {
		return {
			goal: session.projectGoal,
			source: session.projectGoalSource ?? "project-goal",
		};
	}
	return null;
}

export async function ensureGoalContext(
	cwd: string,
	session: SessionData,
	ctx: { ui: { input: (title: string, placeholder?: string) => Promise<string | undefined> } },
): Promise<{
	projectGoal: string;
	projectGoalSource: string;
	sessionGoal?: string;
	sessionGoalSource?: string;
	activeGoal: string;
	activeGoalSource: string;
	session: SessionData;
}> {
	let next = session;

	if (!next.projectGoal?.trim()) {
		const detected = await detectProjectGoal(cwd);
		if (detected) {
			next = { ...next, projectGoal: detected.goal, projectGoalSource: detected.source };
			await saveSession(cwd, next);
		} else {
			const asked = await ctx.ui.input("SASU project goal", "What is the long-term goal of this project?");
			const fallbackGoal = asked?.trim() || "No explicit project goal provided.";
			next = {
				...next,
				projectGoal: fallbackGoal,
				projectGoalSource: asked?.trim() ? "user-input-project" : "unknown",
			};
			await saveSession(cwd, next);
		}
	}

	const active = resolveActiveGoal(next);
	const activeGoal = active?.goal ?? next.projectGoal ?? "No explicit goal provided.";
	const activeGoalSource = active?.source ?? next.projectGoalSource ?? "unknown";

	return {
		projectGoal: next.projectGoal ?? "No explicit project goal provided.",
		projectGoalSource: next.projectGoalSource ?? "unknown",
		sessionGoal: next.sessionGoal,
		sessionGoalSource: next.sessionGoalSource,
		activeGoal,
		activeGoalSource,
		session: next,
	};
}
