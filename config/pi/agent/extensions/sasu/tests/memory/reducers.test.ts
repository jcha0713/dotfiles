import { describe, expect, it } from "bun:test";
import { rebuildSnapshot, reduceFromEvent } from "../../src/memory/reducers";
import { makeMemoryEvent } from "./test-helpers";

describe("memory/reducers", () => {
  it("preserves locked manual focus against explicit intent overwrite", () => {
    const manualFocus = makeMemoryEvent({
      kind: "focus.override.manual",
      ts: "2026-03-05T12:00:00.000Z",
      payload: { focus: "Stabilize review queue semantics" },
    });
    const explicitIntent = makeMemoryEvent({
      kind: "user.intent.explicit",
      ts: "2026-03-05T12:01:00.000Z",
      payload: { intent: "Refactor suggestion parser" },
    });

    let snapshot = reduceFromEvent({}, manualFocus);
    snapshot = reduceFromEvent(snapshot, explicitIntent);

    expect(snapshot.active_focus?.label).toBe("Stabilize review queue semantics");
    expect(snapshot.active_focus?.locked).toBe(true);
    expect(snapshot.intent_hypotheses?.selected?.source).toBe("explicit_intent");
  });

  it("rebuildSnapshot is deterministic by timestamp ordering", () => {
    const events = [
      makeMemoryEvent({
        kind: "check.run.result",
        ts: "2026-03-05T12:03:00.000Z",
        payload: { name: "bun test", status: "pass", files: ["src/memory/brief.ts"] },
      }),
      makeMemoryEvent({
        kind: "code.files.changed",
        ts: "2026-03-05T12:01:00.000Z",
        payload: { files: ["src/memory/brief.ts", "src/memory/brief.ts", "index.ts"] },
      }),
      makeMemoryEvent({
        kind: "check.run.result",
        ts: "2026-03-05T12:02:00.000Z",
        payload: { name: "bun test", status: "fail", files: ["src/memory/brief.ts"] },
      }),
    ];

    const snapshot = rebuildSnapshot(events);
    expect(snapshot.changed_areas?.paths).toEqual(["index.ts", "src/memory/brief.ts"]);
    expect(snapshot.last_checks?.failing).toHaveLength(0);
    expect(snapshot.last_checks?.passing).toHaveLength(1);
    expect(snapshot.last_checks?.passing[0]?.name).toBe("bun test");
  });
});
