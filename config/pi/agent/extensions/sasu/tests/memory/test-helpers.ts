import { randomUUID } from "node:crypto";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import * as path from "node:path";
import type { MemoryEvent, MemoryEventKind, MemoryEventPayload, MemoryEventSource } from "../../src/memory/types";

export async function withTempProject<T>(fn: (cwd: string) => Promise<T>): Promise<T> {
	const cwd = await mkdtemp(path.join(tmpdir(), "sasu-memory-test-"));
	try {
		return await fn(cwd);
	} finally {
		await rm(cwd, { recursive: true, force: true });
	}
}

export function makeMemoryEvent(input: {
	kind: MemoryEventKind;
	source?: MemoryEventSource;
	payload?: MemoryEventPayload;
	projectRoot?: string;
	ts?: string;
	sessionId?: string;
	fingerprint?: string;
}): MemoryEvent {
	return {
		id: randomUUID(),
		ts: input.ts ?? "2026-03-05T00:00:00.000Z",
		projectRoot: input.projectRoot ?? "/tmp/project",
		sessionId: input.sessionId,
		source: input.source ?? "sasu",
		kind: input.kind,
		payload: input.payload ?? {},
		fingerprint: input.fingerprint,
	};
}
