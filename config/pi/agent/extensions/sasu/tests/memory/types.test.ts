import { describe, expect, it } from "bun:test";
import { normalizeMemoryEvent } from "../../src/memory/ingest";
import type { MemoryEventKind } from "../../src/memory/types";

const EVENT_KINDS: MemoryEventKind[] = [
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
];

describe("memory/types validation", () => {
	it("accepts all supported memory event kinds", () => {
		for (const kind of EVENT_KINDS) {
			const normalized = normalizeMemoryEvent({
				projectRoot: "/tmp/project",
				source: "sasu",
				kind,
				payload: { ok: true },
				ts: "2026-03-05T00:00:00.000Z",
				id: `event-${kind}`,
			});
			expect(normalized.kind).toBe(kind);
			expect(typeof normalized.fingerprint).toBe("string");
			expect(normalized.fingerprint?.length).toBe(16);
		}
	});

	it("rejects unknown event kind", () => {
		expect(() =>
			normalizeMemoryEvent({
				projectRoot: "/tmp/project",
				source: "sasu",
				kind: "unknown.kind" as any,
				payload: { ok: true },
			}),
		).toThrow("Unknown memory event kind");
	});

	it("rejects invalid projectRoot and payload", () => {
		expect(() =>
			normalizeMemoryEvent({
				projectRoot: "",
				source: "sasu",
				kind: "user.command.review",
				payload: { ok: true },
			}),
		).toThrow("Memory event requires projectRoot");

		expect(() =>
			normalizeMemoryEvent({
				projectRoot: "/tmp/project",
				source: "sasu",
				kind: "user.command.review",
				payload: [] as any,
			}),
		).toThrow("Memory event payload must be an object");
	});
});
