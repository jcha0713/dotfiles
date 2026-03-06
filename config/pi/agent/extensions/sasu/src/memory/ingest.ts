import { createHash, randomUUID } from "node:crypto";
import { MemoryStore } from "./store";
import { reduceFromEvent } from "./reducers";
import type { MemoryEvent, MemoryEventKind, MemoryEventPayload, MemoryEventSource, WorkingStateByKey, WorkingStateKey } from "./types";

const EVENT_KINDS: Set<MemoryEventKind> = new Set([
	"user.command.review",
	"user.command.suggest",
	"user.command.goal_set",
	"user.intent.explicit",
	"code.git.snapshot",
	"code.files.changed",
	"check.run.result",
	"agent.review.requested",
	"agent.review.completed",
	"agent.suggestion.generated",
	"user.suggestion.action",
	"focus.override.manual",
]);

export interface MemoryEventInput {
	projectRoot: string;
	source: MemoryEventSource;
	kind: MemoryEventKind;
	payload: MemoryEventPayload;
	sessionId?: string;
	ts?: string;
	id?: string;
	fingerprint?: string;
}

function assertMemoryEventKind(kind: string): asserts kind is MemoryEventKind {
	if (!EVENT_KINDS.has(kind as MemoryEventKind)) {
		throw new Error(`Unknown memory event kind: ${kind}`);
	}
}

function normalizeTimestamp(ts?: string): string {
	if (!ts || ts.trim().length === 0) return new Date().toISOString();
	return ts;
}

function computeFingerprint(input: MemoryEventInput): string {
	const basis = JSON.stringify({
		projectRoot: input.projectRoot,
		kind: input.kind,
		source: input.source,
		payload: input.payload,
	});
	return createHash("sha256").update(basis).digest("hex").slice(0, 16);
}

const DEDUP_WINDOW_MS = 30_000;

function computeDedupSinceTs(ts: string): string | null {
	const parsed = Date.parse(ts);
	if (!Number.isFinite(parsed)) return null;
	return new Date(parsed - DEDUP_WINDOW_MS).toISOString();
}

async function findDuplicateEvent(store: MemoryStore, event: MemoryEvent): Promise<MemoryEvent | null> {
	const sinceTs = computeDedupSinceTs(event.ts);
	if (!sinceTs) return null;
	return store.findRecentEventByFingerprint({
		projectRoot: event.projectRoot,
		sessionId: event.sessionId,
		fingerprint: event.fingerprint,
		sinceTs,
		untilTs: event.ts,
	});
}

function isBatchDuplicate(existingEvents: MemoryEvent[], event: MemoryEvent): boolean {
	if (!event.fingerprint || event.fingerprint.trim().length === 0) return false;
	const targetTs = Date.parse(event.ts);
	if (!Number.isFinite(targetTs)) return false;
	return existingEvents.some((existing) => {
		if (existing.projectRoot !== event.projectRoot) return false;
		if ((existing.sessionId ?? null) !== (event.sessionId ?? null)) return false;
		if (existing.fingerprint !== event.fingerprint) return false;
		const existingTs = Date.parse(existing.ts);
		if (!Number.isFinite(existingTs)) return false;
		return Math.abs(targetTs - existingTs) <= DEDUP_WINDOW_MS;
	});
}

export function normalizeMemoryEvent(input: MemoryEventInput): MemoryEvent {
	if (!input.projectRoot || input.projectRoot.trim().length === 0) {
		throw new Error("Memory event requires projectRoot");
	}
	if (!input.payload || typeof input.payload !== "object" || Array.isArray(input.payload)) {
		throw new Error("Memory event payload must be an object");
	}
	assertMemoryEventKind(input.kind);

	return {
		id: input.id ?? randomUUID(),
		ts: normalizeTimestamp(input.ts),
		projectRoot: input.projectRoot,
		sessionId: input.sessionId,
		source: input.source,
		kind: input.kind,
		payload: input.payload,
		fingerprint: input.fingerprint ?? computeFingerprint(input),
	};
}

async function persistStateUpdates(store: MemoryStore, updates: Partial<WorkingStateByKey>): Promise<void> {
	const entries = Object.entries(updates) as Array<[WorkingStateKey, WorkingStateByKey[WorkingStateKey]]>;
	for (const [key, value] of entries) {
		await store.upsertWorkingState(key, value);
	}
}

export async function ingestEvent(store: MemoryStore, input: MemoryEventInput): Promise<MemoryEvent> {
	const event = normalizeMemoryEvent(input);
	const duplicate = await findDuplicateEvent(store, event);
	if (duplicate) return duplicate;

	await store.appendEvent(event);
	const snapshot = await store.getWorkingStateSnapshot();
	const updates = reduceFromEvent(snapshot, event);
	await persistStateUpdates(store, updates);
	return event;
}

export async function ingestEvents(store: MemoryStore, inputs: MemoryEventInput[]): Promise<MemoryEvent[]> {
	if (inputs.length === 0) return [];
	const normalized = inputs.map((input) => normalizeMemoryEvent(input));
	const accepted: MemoryEvent[] = [];

	for (const event of normalized) {
		if (isBatchDuplicate(accepted, event)) continue;
		const duplicate = await findDuplicateEvent(store, event);
		if (duplicate) continue;
		accepted.push(event);
	}

	if (accepted.length === 0) return [];
	await store.appendEvents(accepted);

	let snapshot = await store.getWorkingStateSnapshot();
	for (const event of accepted) {
		snapshot = reduceFromEvent(snapshot, event);
	}
	await persistStateUpdates(store, snapshot);
	return accepted;
}
