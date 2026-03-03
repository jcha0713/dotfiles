import { access } from "node:fs/promises";
import * as path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { runExec } from "./exec";
import type { Nullable, SuggestedFile } from "./types";

const KNOWN_FILE_BASENAMES = new Set([
	"makefile",
	"dockerfile",
	"justfile",
	"license",
	"copying",
	"readme",
	"changelog",
	"authors",
	"contributors",
]);

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
	if (p.length === 0 || p.includes(" ")) return null;

	const base = path.basename(p).toLowerCase();
	const fileLike = base.includes(".") || KNOWN_FILE_BASENAMES.has(base);
	if (!fileLike) return null;

	return p;
}

export function extractSuggestedPathsFromCandidates(
	text: string,
	candidatePaths: string[],
	max = 40,
): SuggestedFile[] {
	const normalizedCandidates = Array.from(
		new Set(candidatePaths.map((candidatePath) => normalizeSuggestedPath(candidatePath)).filter(Boolean) as string[]),
	).sort((a, b) => b.length - a.length);
	const candidateSet = new Set(normalizedCandidates);

	const suggestions: SuggestedFile[] = [];
	const seen = new Set<string>();

	for (const rawLine of text.split("\n")) {
		const line = rawLine.trim();
		if (!line) continue;

		const isListLike = /^(?:[-*+]\s+|\d+[.)]\s+)/.test(line);
		const inlineCodeTokens = Array.from(line.matchAll(/`([^`]+)`/g))
			.map((m) => normalizeSuggestedPath(m[1] || ""))
			.filter((token): token is string => Boolean(token));
		if (!isListLike && inlineCodeTokens.length === 0) continue;

		let selectedPath: string | null = null;
		for (const token of inlineCodeTokens) {
			if (candidateSet.has(token)) {
				selectedPath = token;
				break;
			}
		}

		if (!selectedPath) {
			for (const candidatePath of normalizedCandidates) {
				if (line.includes(candidatePath)) {
					selectedPath = candidatePath;
					break;
				}
			}
		}
		if (!selectedPath || seen.has(selectedPath)) continue;

		const strippedPrefix = line.replace(/^\s*(?:[-*+]\s+|\d+[.)]\s+)/, "");
		const rawReason = strippedPrefix.replace(selectedPath, "").replace(/^[-–—:\s]+/, "").trim();
		seen.add(selectedPath);
		suggestions.push({
			path: selectedPath,
			reason: sanitizeReason(rawReason),
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

export async function normalizeSuggestedFilesForProject(
	pi: ExtensionAPI,
	cwd: string,
	suggestions: SuggestedFile[],
	max = 40,
): Promise<SuggestedFile[]> {
	const projectFiles = await listProjectFiles(pi, cwd);
	const normalized: SuggestedFile[] = [];
	const seen = new Set<string>();

	for (const suggestion of suggestions) {
		const candidate = normalizeSuggestedPath(suggestion.path);
		if (!candidate) continue;

		let resolved: string | null = null;
		if (path.isAbsolute(candidate)) {
			if (await pathExists(candidate)) {
				resolved = path.relative(cwd, candidate).replace(/\\/g, "/");
			}
		} else {
			const direct = path.join(cwd, candidate);
			if (await pathExists(direct)) {
				resolved = candidate.replace(/^\.\//, "");
			} else {
				resolved = findBestProjectRelativePath(candidate, projectFiles);
			}
		}

		if (resolved) {
			const resolvedAbsolutePath = path.join(cwd, resolved);
			if (!(await pathExists(resolvedAbsolutePath))) {
				resolved = null;
			}
		}
		if (!resolved || seen.has(resolved)) continue;

		seen.add(resolved);
		normalized.push({
			path: resolved,
			reason: sanitizeReason(suggestion.reason),
		});

		if (normalized.length >= max) break;
	}

	return normalized;
}
