import { access } from "node:fs/promises";
import * as path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { runExec } from "./exec";
import type { Nullable, SuggestedFile, SuggestionAction } from "./types";

export function extractTextFromMessage(message: any): string {
	if (!message) return "";
	const content = message.content;
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.map((part) => {
			if (typeof part === "string") return part;
			if (part?.type === "text" && typeof part.text === "string") return part.text;
			return "";
		})
		.filter(Boolean)
		.join("\n");
}

function sanitizeReason(reason: string | undefined): string | undefined {
	if (!reason) return undefined;
	const cleaned = reason
		.replace(/[`*_~]+/g, "")
		.replace(/^[-–—:\s]+/, "")
		.replace(/\s+/g, " ")
		.trim();

	if (!cleaned || /^[\W_]+$/.test(cleaned)) return undefined;
	return cleaned;
}

function normalizeSuggestedPath(rawPath: string): Nullable<string> {
	let p = rawPath.trim();
	if (!p) return null;

	p = p
		.replace(/^['"`]+/, "")
		.replace(/['"`]+$/, "")
		.replace(/^[\[(]+/, "")
		.replace(/[\])]+$/, "")
		.replace(/[,:;.]$/, "")
		.trim();

	if (!p) return null;
	if (p.includes("://") || p.startsWith("http")) return null;
	if (p.startsWith("./")) p = p.slice(2);
	p = p.replace(/\\/g, "/");
	p = p.replace(/\/+/g, "/");
	if (p.length === 0 || /\s/.test(p) || p === "." || p === "..") return null;

	return p;
}

function normalizeCreatePath(rawPath: string): Nullable<string> {
	if (!rawPath) return null;
	if (path.isAbsolute(rawPath)) return null;

	const normalized = path.posix.normalize(rawPath.replace(/^\.\//, ""));
	if (!normalized || normalized === "." || normalized === "..") return null;
	if (normalized.startsWith("../") || normalized.includes("/../")) return null;
	if (normalized.endsWith("/")) return null;
	return normalized;
}

function parseSuggestionLine(rawLine: string): Nullable<{ action: SuggestionAction; path: string; reason?: string }> {
	const listStripped = rawLine.trim().replace(/^(?:[-*+]\s+|\d+[.)]\s+)/, "").trim();
	if (!listStripped) return null;

	const actionMatch = listStripped.match(/^(OPEN|CREATE)\b/i);
	if (!actionMatch) return null;

	const action = actionMatch[1].toLowerCase() === "create" ? "create" : "open";
	let rest = listStripped.slice(actionMatch[0].length).replace(/^[-–—:\s]+/, "").trim();
	if (!rest) return null;

	let rawPath = "";
	let rawReason = "";

	if (rest.startsWith("`")) {
		const closingTick = rest.indexOf("`", 1);
		if (closingTick > 1) {
			rawPath = rest.slice(1, closingTick);
			rawReason = rest.slice(closingTick + 1);
		} else {
			rawPath = rest.slice(1);
		}
	} else {
		const separatorMatch = rest.match(/\s+[—–-]\s+/);
		if (separatorMatch && typeof separatorMatch.index === "number") {
			rawPath = rest.slice(0, separatorMatch.index);
			rawReason = rest.slice(separatorMatch.index + separatorMatch[0].length);
		} else {
			rawPath = rest;
		}
	}

	const normalizedPath = normalizeSuggestedPath(rawPath);
	if (!normalizedPath) return null;

	return {
		action,
		path: normalizedPath,
		reason: sanitizeReason(rawReason),
	};
}

export function extractSuggestedFilesFromResponse(
	text: string,
	candidatePaths: string[],
	max = 40,
): SuggestedFile[] {
	const normalizedCandidates = Array.from(
		new Set(candidatePaths.map((candidatePath) => normalizeSuggestedPath(candidatePath)).filter(Boolean) as string[]),
	);
	const candidateSet = new Set(normalizedCandidates);

	const suggestions: SuggestedFile[] = [];
	const pathIndex = new Map<string, number>();

	for (const rawLine of text.split("\n")) {
		const parsed = parseSuggestionLine(rawLine);
		if (!parsed) continue;

		let action: SuggestionAction = parsed.action;
		let resolvedPath: string | null = null;

		if (action === "open") {
			if (!candidateSet.has(parsed.path)) continue;
			resolvedPath = parsed.path;
		} else {
			const createPath = normalizeCreatePath(parsed.path);
			if (!createPath) continue;
			if (candidateSet.has(createPath)) {
				action = "open";
			}
			resolvedPath = createPath;
		}

		if (!resolvedPath) continue;

		const existingIndex = pathIndex.get(resolvedPath);
		if (typeof existingIndex === "number") {
			const existing = suggestions[existingIndex];
			if (existing.action === "create" && action === "open") {
				suggestions[existingIndex] = {
					path: resolvedPath,
					action,
					reason: sanitizeReason(parsed.reason),
				};
			}
			continue;
		}

		pathIndex.set(resolvedPath, suggestions.length);
		suggestions.push({
			path: resolvedPath,
			action,
			reason: sanitizeReason(parsed.reason),
		});
		if (suggestions.length >= max) break;
	}

	return suggestions;
}

async function pathExists(filePath: string): Promise<boolean> {
	try {
		await access(filePath);
		return true;
	} catch {
		return false;
	}
}

async function filterExistingProjectFiles(cwd: string, filePaths: string[]): Promise<string[]> {
	const unique = Array.from(new Set(filePaths.map((filePath) => filePath.trim().replace(/^\.\//, "")).filter(Boolean)));
	const existing = await Promise.all(
		unique.map(async (relativePath) => {
			const absolutePath = path.join(cwd, relativePath);
			return (await pathExists(absolutePath)) ? relativePath : null;
		}),
	);
	return existing.filter((filePath): filePath is string => typeof filePath === "string");
}

export async function listProjectFiles(pi: ExtensionAPI, cwd: string): Promise<string[]> {
	const tracked = await runExec(pi, "git", ["ls-files", "--cached", "--others", "--exclude-standard"], 20_000);
	if (tracked.code === 0) {
		const trackedFiles = tracked.stdout
			.split("\n")
			.map((line) => line.trim())
			.filter((line) => line.length > 0);
		return filterExistingProjectFiles(cwd, trackedFiles);
	}

	const found = await runExec(
		pi,
		"bash",
		[
			"-lc",
			"find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './dist/*' | head -n 4000",
		],
		20_000,
	);
	if (found.code !== 0) return [];

	const foundFiles = found.stdout
		.split("\n")
		.map((line) => line.trim().replace(/^\.\//, ""))
		.filter((line) => line.length > 0);
	return filterExistingProjectFiles(cwd, foundFiles);
}

function findBestProjectRelativePath(candidate: string, projectFiles: string[]): string | null {
	const normalizedCandidate = candidate.replace(/^\.\//, "");
	const fileSet = new Set(projectFiles);
	if (fileSet.has(normalizedCandidate)) return normalizedCandidate;

	const suffixMatches = projectFiles.filter(
		(filePath) =>
			normalizedCandidate === filePath ||
			normalizedCandidate.endsWith(`/${filePath}`) ||
			normalizedCandidate.endsWith(`\\${filePath}`),
	);
	if (suffixMatches.length > 0) {
		suffixMatches.sort((a, b) => b.length - a.length);
		return suffixMatches[0];
	}

	const parts = normalizedCandidate.split(/[\\/]+/).filter(Boolean);
	for (let i = 1; i < parts.length; i += 1) {
		const trial = parts.slice(i).join("/");
		if (fileSet.has(trial)) return trial;
	}

	return null;
}

async function resolveExistingPath(cwd: string, candidate: string, projectFiles: string[]): Promise<string | null> {
	if (path.isAbsolute(candidate)) {
		if (!(await pathExists(candidate))) return null;
		const relative = path.relative(cwd, candidate).replace(/\\/g, "/");
		if (!relative || relative.startsWith("../") || relative === "..") return null;
		return relative;
	}

	const direct = path.join(cwd, candidate);
	if (await pathExists(direct)) {
		return candidate.replace(/^\.\//, "");
	}

	return findBestProjectRelativePath(candidate, projectFiles);
}

export async function normalizeSuggestedFilesForProject(
	pi: ExtensionAPI,
	cwd: string,
	suggestions: SuggestedFile[],
	max = 40,
): Promise<SuggestedFile[]> {
	const projectFiles = await listProjectFiles(pi, cwd);
	const projectFileSet = new Set(projectFiles);
	const normalized: SuggestedFile[] = [];
	const pathIndex = new Map<string, number>();

	for (const suggestion of suggestions) {
		const normalizedPath = normalizeSuggestedPath(suggestion.path);
		if (!normalizedPath) continue;

		let action: SuggestionAction = suggestion.action === "create" ? "create" : "open";
		let resolvedPath: string | null = null;

		if (action === "create") {
			const createPath = normalizeCreatePath(normalizedPath);
			if (!createPath) continue;

			const absoluteCreatePath = path.join(cwd, createPath);
			if (projectFileSet.has(createPath) || (await pathExists(absoluteCreatePath))) {
				action = "open";
				resolvedPath = createPath;
			} else {
				resolvedPath = createPath;
			}
		} else {
			resolvedPath = await resolveExistingPath(cwd, normalizedPath, projectFiles);
			if (!resolvedPath) continue;
			const resolvedAbsolutePath = path.join(cwd, resolvedPath);
			if (!(await pathExists(resolvedAbsolutePath))) continue;
		}

		const existingIndex = pathIndex.get(resolvedPath);
		if (typeof existingIndex === "number") {
			const existing = normalized[existingIndex];
			if (existing.action === "create" && action === "open") {
				normalized[existingIndex] = {
					path: resolvedPath,
					action,
					reason: sanitizeReason(suggestion.reason),
				};
			}
			continue;
		}

		pathIndex.set(resolvedPath, normalized.length);
		normalized.push({
			path: resolvedPath,
			action,
			reason: sanitizeReason(suggestion.reason),
		});

		if (normalized.length >= max) break;
	}

	return normalized;
}
