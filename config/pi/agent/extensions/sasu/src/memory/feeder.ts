import * as path from "node:path";
import type { MemoryEventKind, MemoryEventPayload } from "./types";

export interface NvimFeederEnvelope {
  source: "nvim";
  kind: MemoryEventKind;
  payload: MemoryEventPayload;
  projectRoot: string;
  ts: string;
  sessionId?: string;
}

export interface NvimBufWriteSignalInput {
  filePath: string;
  projectRoot: string;
  ts?: string;
  sessionId?: string;
  origin?: string;
  reason?: string;
}

const FORBIDDEN_TEXT_KEYS = new Set([
  "text",
  "fulltext",
  "rawtext",
  "buffer",
  "buffertext",
  "snapshot",
]);
const PATH_FIELD_KEYS = new Set(["file", "path"]);
const PATH_LIST_FIELD_KEYS = new Set(["files"]);
const MAX_PAYLOAD_CHARS = 4096;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function asNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function normalizeTimestamp(ts?: string): string {
  const parsed = asNonEmptyString(ts) ?? new Date().toISOString();
  if (!Number.isFinite(Date.parse(parsed))) {
    throw new Error("ts must be a valid timestamp");
  }
  return parsed;
}

function assertProjectRelativePath(rawPath: string, fieldPath: string): string {
  const normalizedSlashes = rawPath.trim().replace(/\\/g, "/");
  if (!normalizedSlashes) {
    throw new Error(`payload.${fieldPath} must be a non-empty project-relative path`);
  }
  if (path.isAbsolute(normalizedSlashes)) {
    throw new Error(
      `payload.${fieldPath} must be project-relative (absolute paths are not allowed)`,
    );
  }
  const normalized = path.posix.normalize(normalizedSlashes).replace(/^\.\//, "");
  if (!normalized || normalized === "." || normalized === ".." || normalized.startsWith("../")) {
    throw new Error(`payload.${fieldPath} must stay inside project root`);
  }
  return normalized;
}

export function normalizeNvimFilePath(rawPath: string, projectRoot: string): string {
  const normalizedInput = asNonEmptyString(rawPath);
  if (!normalizedInput) {
    throw new Error("filePath is required");
  }

  const normalizedProjectRoot = path.resolve(projectRoot);
  const slashNormalized = normalizedInput.replace(/\\/g, "/");
  if (path.isAbsolute(slashNormalized)) {
    const absoluteResolved = path.resolve(slashNormalized);
    const relative = path.relative(normalizedProjectRoot, absoluteResolved).replace(/\\/g, "/");
    return assertProjectRelativePath(relative, "files[0]");
  }

  return assertProjectRelativePath(slashNormalized, "files[0]");
}

function normalizePayloadValue(value: unknown, fieldName: string, fieldPath: string): unknown {
  const normalizedFieldName = fieldName.toLowerCase();
  if (typeof value === "string") {
    if (PATH_FIELD_KEYS.has(normalizedFieldName)) {
      return assertProjectRelativePath(value, fieldPath);
    }
    return value;
  }

  if (Array.isArray(value)) {
    if (PATH_LIST_FIELD_KEYS.has(normalizedFieldName)) {
      const paths = value.map((entry, index) => {
        if (typeof entry !== "string") {
          throw new Error(`payload.${fieldPath}[${index}] must be a project-relative path string`);
        }
        return assertProjectRelativePath(entry, `${fieldPath}[${index}]`);
      });
      return Array.from(new Set(paths));
    }
    return value.map((entry, index) => normalizePayloadValue(entry, "", `${fieldPath}[${index}]`));
  }

  if (isRecord(value)) {
    const next: Record<string, unknown> = {};
    for (const [key, child] of Object.entries(value)) {
      const lowerKey = key.toLowerCase();
      if (FORBIDDEN_TEXT_KEYS.has(lowerKey)) {
        throw new Error(
          `payload.${fieldPath ? `${fieldPath}.` : ""}${key} is not allowed (raw text/buffer payloads are forbidden)`,
        );
      }
      const childFieldPath = fieldPath ? `${fieldPath}.${key}` : key;
      next[key] = normalizePayloadValue(child, key, childFieldPath);
    }
    return next;
  }

  return value;
}

function normalizePayload(payload: unknown): MemoryEventPayload {
  if (!isRecord(payload)) {
    throw new Error("payload must be a JSON object");
  }
  const normalized = normalizePayloadValue(payload, "", "");
  if (!isRecord(normalized)) {
    throw new Error("payload must be a JSON object");
  }
  const serialized = JSON.stringify(normalized);
  if (serialized.length > MAX_PAYLOAD_CHARS) {
    throw new Error(`payload is too large for feeder contract (max ${MAX_PAYLOAD_CHARS} chars)`);
  }
  return normalized;
}

export function normalizeNvimFeederEnvelope(
  raw: unknown,
  expectedProjectRoot: string,
): NvimFeederEnvelope {
  if (!isRecord(raw)) {
    throw new Error("Neovim feeder event must be a JSON object");
  }

  const source = asNonEmptyString(raw.source);
  if (source !== "nvim") {
    throw new Error('source must be "nvim"');
  }

  const kind = asNonEmptyString(raw.kind);
  if (!kind) {
    throw new Error("kind is required");
  }

  const projectRoot = asNonEmptyString(raw.projectRoot);
  if (!projectRoot) {
    throw new Error("projectRoot is required");
  }
  const expectedRootResolved = path.resolve(expectedProjectRoot);
  const incomingRootResolved = path.resolve(projectRoot);
  if (incomingRootResolved !== expectedRootResolved) {
    throw new Error(`projectRoot mismatch (expected ${expectedRootResolved})`);
  }

  const ts = asNonEmptyString(raw.ts);
  if (!ts) {
    throw new Error("ts is required");
  }
  if (!Number.isFinite(Date.parse(ts))) {
    throw new Error("ts must be a valid timestamp");
  }

  const payload = normalizePayload(raw.payload);
  const sessionId = asNonEmptyString(raw.sessionId) ?? undefined;

  return {
    source: "nvim",
    kind: kind as MemoryEventKind,
    payload,
    projectRoot: expectedRootResolved,
    ts,
    sessionId,
  };
}

export function buildNvimBufWriteEnvelope(input: NvimBufWriteSignalInput): NvimFeederEnvelope {
  const projectRootInput = asNonEmptyString(input.projectRoot);
  if (!projectRootInput) {
    throw new Error("projectRoot is required");
  }
  const projectRoot = path.resolve(projectRootInput);
  const normalizedPath = normalizeNvimFilePath(input.filePath, projectRoot);
  const origin = asNonEmptyString(input.origin) ?? "nvim.buf_write";
  const reason = asNonEmptyString(input.reason) ?? "save";
  const ts = normalizeTimestamp(input.ts);
  const sessionId = asNonEmptyString(input.sessionId) ?? undefined;

  return normalizeNvimFeederEnvelope(
    {
      source: "nvim",
      kind: "code.files.changed",
      payload: {
        origin,
        files: [normalizedPath],
        reason,
      },
      projectRoot,
      ts,
      sessionId,
    },
    projectRoot,
  );
}
