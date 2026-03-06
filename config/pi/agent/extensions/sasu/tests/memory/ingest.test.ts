import { describe, expect, it } from "bun:test";
import { ingestEvent, normalizeMemoryEvent } from "../../src/memory/ingest";
import { createMemoryStore } from "../../src/memory/store";
import { withTempProject } from "./test-helpers";

describe("memory/ingest", () => {
	it("computes stable fingerprint for equivalent normalized events", () => {
		const first = normalizeMemoryEvent({
			projectRoot: "/tmp/project",
			source: "sasu",
			kind: "user.command.review",
			payload: { intent: "review auth flow" },
			id: "event-1",
			ts: "2026-03-05T11:00:00.000Z",
		});
		const second = normalizeMemoryEvent({
			projectRoot: "/tmp/project",
			source: "sasu",
			kind: "user.command.review",
			payload: { intent: "review auth flow" },
			id: "event-2",
			ts: "2026-03-05T11:05:00.000Z",
		});

		expect(first.fingerprint).toBeDefined();
		expect(first.fingerprint).toBe(second.fingerprint);
	});

	it("ingestEvent updates working state via reducers", async () => {
		await withTempProject(async (cwd) => {
			const store = await createMemoryStore(cwd);
			await ingestEvent(store, {
				projectRoot: cwd,
				source: "pi",
				kind: "user.intent.explicit",
				payload: { intent: "Wire mission brief into review" },
				ts: "2026-03-05T11:10:00.000Z",
			});

			const intentState = await store.getWorkingState("intent_hypotheses");
			expect(intentState?.selected?.label).toBe("Wire mission brief into review");
			expect(intentState?.selected?.source).toBe("explicit_intent");
		});
	});

	it("deduplicates recent events by fingerprint while allowing later repeats", async () => {
		await withTempProject(async (cwd) => {
			const store = await createMemoryStore(cwd);

			const first = await ingestEvent(store, {
				projectRoot: cwd,
				source: "sasu",
				kind: "user.command.review",
				payload: { intent: "review queue semantics" },
				ts: "2026-03-05T11:20:00.000Z",
				sessionId: "session-1",
			});

			const duplicate = await ingestEvent(store, {
				projectRoot: cwd,
				source: "sasu",
				kind: "user.command.review",
				payload: { intent: "review queue semantics" },
				ts: "2026-03-05T11:20:05.000Z",
				sessionId: "session-1",
			});

			expect(duplicate.id).toBe(first.id);
			expect(await store.getEventTotalCount({ projectRoot: cwd, sessionId: "session-1" })).toBe(1);

			await ingestEvent(store, {
				projectRoot: cwd,
				source: "sasu",
				kind: "user.command.review",
				payload: { intent: "review queue semantics" },
				ts: "2026-03-05T11:21:00.000Z",
				sessionId: "session-1",
			});

			expect(await store.getEventTotalCount({ projectRoot: cwd, sessionId: "session-1" })).toBe(2);
		});
	});
});
