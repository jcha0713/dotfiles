import { describe, expect, it } from "bun:test";
import * as path from "node:path";
import { createMemoryStore } from "../../src/memory/store";
import { makeMemoryEvent, withTempProject } from "./test-helpers";

describe("memory/store", () => {
	it("initializes context DB and supports event roundtrip", async () => {
		await withTempProject(async (cwd) => {
			const store = await createMemoryStore(cwd);
			expect(store.getDbPath()).toBe(path.join(cwd, ".sasu", "context.db"));

			const event = makeMemoryEvent({
				kind: "user.command.review",
				projectRoot: cwd,
				ts: "2026-03-05T10:00:00.000Z",
				payload: { rawArgs: "--show-prompt" },
			});
			await store.appendEvent(event);

			const events = await store.queryEvents({ projectRoot: cwd, limit: 10 });
			expect(events).toHaveLength(1);
			expect(events[0]?.id).toBe(event.id);
			expect(events[0]?.kind).toBe("user.command.review");

			const total = await store.getEventTotalCount({ projectRoot: cwd });
			expect(total).toBe(1);

			const counts = await store.getEventCountsByKind({ projectRoot: cwd });
			expect(counts["user.command.review"]).toBe(1);
		});
	});

	it("upserts working state and resetAll clears persisted state", async () => {
		await withTempProject(async (cwd) => {
			const store = await createMemoryStore(cwd);
			await store.upsertWorkingState("active_focus", {
				label: "Memory v0 review integration",
				source: "focus.override.manual",
				locked: true,
				updatedAt: "2026-03-05T10:01:00.000Z",
			});

			const activeFocus = await store.getWorkingState("active_focus");
			expect(activeFocus?.label).toBe("Memory v0 review integration");

			await store.appendFeedback({
				id: "feedback-1",
				ts: "2026-03-05T10:02:00.000Z",
				action: "accepted",
				suggestionId: "src/memory/brief.ts",
				context: { fromTest: true },
			});

			await store.resetAll();
			expect(await store.getEventTotalCount({ projectRoot: cwd })).toBe(0);
			expect(await store.getWorkingStateSnapshot()).toEqual({});
		});
	});
});
