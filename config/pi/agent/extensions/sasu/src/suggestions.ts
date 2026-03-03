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

function addSuggestedFile(target: SuggestedFile[], file: SuggestedFile): void {
	const normalized = normalizeSuggestedPath(file.path);
	if (!normalized) return;
	if (target.some((existing) => existing.path === normalized)) return;
	target.push({
		path: normalized,
		reason: sanitizeReason(file.reason),
	});
}

export function extractSuggestedFilesFromJsonBlock(text: string): SuggestedFile[] {
	const suggestions: SuggestedFile[] = [];
	const fenceRegex = /```(?:json)?\s*([\s\S]*?)```/gim;
	let match: RegExpExecArray | null;

	const collect = (node: any) => {
		if (!node) return;
		if (Array.isArray(node)) {
			for (const item of node) collect(item);
			return;
		}
		if (typeof node === "string") {
			addSuggestedFile(suggestions, { path: node });
			return;
		}
		if (typeof node !== "object") return;
		if (typeof node.path === "string") {
			addSuggestedFile(suggestions, {
				path: node.path,
				reason: typeof node.reason === "string" ? node.reason : undefined,
			});
		}
		for (const key of ["suggested_files", "suggestedFiles", "files", "next_files", "nextFiles"]) {
			if (key in node) collect(node[key]);
		}
	};

	while ((match = fenceRegex.exec(text)) !== null) {
		const block = match[1]?.trim();
		if (!block) continue;
		try {
			collect(JSON.parse(block));
		} catch {
			// Ignore invalid JSON blocks.
		}
	}

	return suggestions;
}

function pickCandidateFromListLine(line: string): string | null {
	const withoutPrefix = line.replace(/^\s*(?:[-*+]\s+|\d+[.)]\s+)/, "").trim();
	if (!withoutPrefix) return null;

	const beforeReason = withoutPrefix.split(/\s+[–—-]\s+|\s*:\s+/)[0]?.trim();
	if (beforeReason) return beforeReason;
	return null;
}

function extractSuggestedFilesFromLines(text: string): SuggestedFile[] {
	const suggestions: SuggestedFile[] = [];
	const lines = text.split("\n");

	for (const rawLine of lines) {
		const line = rawLine.trim();
		if (!line) continue;

		const isListItem = /^\s*(?:[-*+]\s+|\d+[.)]\s+)/.test(rawLine);
		const hasInlineCode = /`[^`]+`/.test(line);
		if (!isListItem && !hasInlineCode) continue;

		const candidates: string[] = [];
		for (const m of line.matchAll(/`([^`]+)`/g)) {
			if (m[1]) candidates.push(m[1]);
		}
		if (isListItem) {
			const fromListPrefix = pickCandidateFromListLine(line);
			if (fromListPrefix) candidates.push(fromListPrefix);
		}
		const fromPath = line.match(/(?:^|\s)(\.?\/?[A-Za-z0-9._-]+(?:\/[A-Za-z0-9._-]+)*)/g) ?? [];
		for (const token of fromPath) {
			candidates.push(token.trim());
		}

		let normalizedPath: string | null = null;
		let usedToken: string | null = null;
		for (const candidate of candidates) {
			const normalized = normalizeSuggestedPath(candidate);
			if (normalized) {
				normalizedPath = normalized;
				usedToken = candidate;
				break;
			}
		}
		if (!normalizedPath) continue;

		const strippedPrefix = line.replace(/^\s*(?:[-*+]\s+|\d+[.)]\s+)/, "");
		const rawReason = usedToken
			? strippedPrefix.replace(usedToken, "").replace(/^[-–—:\s]+/, "").trim()
			: "";

		addSuggestedFile(suggestions, {
			path: normalizedPath,
			reason: rawReason,
		});
	}

	return suggestions;
}

export function extractSuggestedFiles(text: string, max = 40): SuggestedFile[] {
	const jsonFiles = extractSuggestedFilesFromJsonBlock(text);
	const lineFiles = extractSuggestedFilesFromLines(text);
	const merged: SuggestedFile[] = [];
	for (const s of [...jsonFiles, ...lineFiles]) addSuggestedFile(merged, s);
	return merged.slice(0, max);
}

export async function listProjectFiles(pi: ExtensionAPI): Promise<string[]> {
	const tracked = await runExec(pi, "git", ["ls-files", "--cached", "--others", "--exclude-standard"], 20_000);
	if (tracked.code === 0) {
		return tracked.stdout
			.split("\n")
			.map((line) => line.trim())
			.filter((line) => line.length > 0);
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

	return found.stdout
		.split("\n")
		.map((line) => line.trim().replace(/^\.\//, ""))
		.filter((line) => line.length > 0);
}

async function pathExists(filePath: string): Promise<boolean> {
	try {
		await access(filePath);
		return true;
	} catch {
		return false;
	}
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
	const projectFiles = await listProjectFiles(pi);
	const normalized: SuggestedFile[] = [];

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

		if (!resolved) continue;
		addSuggestedFile(normalized, {
			path: resolved,
			reason: suggestion.reason,
		});
		if (normalized.length >= max) break;
	}

	return normalized;
}

