import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";

type EventKind =
  | "user.command.review"
  | "user.command.suggest"
  | "user.command.goal_set"
  | "user.intent.explicit"
  | "code.git.snapshot"
  | "code.files.changed"
  | "check.run.result"
  | "agent.review.requested"
  | "agent.review.completed"
  | "agent.suggestion.generated"
  | "user.suggestion.action"
  | "focus.override.manual";

type MemoryEvent = {
  id: string;
  ts: string;
  source: "pi" | "sasu" | "nvim" | "git" | "check";
  kind: EventKind;
  payload: Record<string, unknown>;
  fingerprint?: string;
};

type Summary = {
  totalEvents: number;
  byKind: Record<string, number>;
  selectedIntent: {
    label: string;
    confidence: number;
    source: "manual_override" | "explicit_intent" | "changed_area" | "fallback";
  };
  changedAreas: string[];
  failingChecks: Array<{ name: string; files: string[] }>;
  topRisks: Array<{ type: string; impact: number; confidence: number; evidence: string[]; nextStep: string }>;
  brief: string;
};

const EVENT_KINDS = new Set<EventKind>([
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

function parseArgs(argv: string[]) {
  const args = {
    fixture: "tests/fixtures/memory/events-basic.json",
    snapshot: "tests/fixtures/memory/expected-summary.json",
    updateSnapshot: false,
    charBudget: 3200,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--fixture") args.fixture = argv[++i];
    else if (arg === "--snapshot") args.snapshot = argv[++i];
    else if (arg === "--update-snapshot") args.updateSnapshot = true;
    else if (arg === "--char-budget") args.charBudget = Number(argv[++i]);
    else if (arg === "--help" || arg === "-h") {
      console.log("Usage: bun run scripts/replay-memory-smoke.ts [--fixture FILE] [--snapshot FILE] [--update-snapshot] [--char-budget N]");
      process.exit(0);
    } else {
      throw new Error(`Unknown arg: ${arg}`);
    }
  }

  return args;
}

function normalizeRel(p: string): string {
  return p.replace(/\\/g, "/").replace(/^\.\//, "");
}

function topDir(filePath: string): string {
  const rel = normalizeRel(filePath);
  return rel.split("/")[0] || rel;
}

function validateEvents(events: unknown): MemoryEvent[] {
  if (!Array.isArray(events)) {
    throw new Error("Fixture must be an array");
  }

  return events.map((raw, idx) => {
    if (!raw || typeof raw !== "object") {
      throw new Error(`Event #${idx + 1}: must be object`);
    }

    const event = raw as Partial<MemoryEvent>;
    if (!event.id || typeof event.id !== "string") throw new Error(`Event #${idx + 1}: missing id`);
    if (!event.ts || typeof event.ts !== "string") throw new Error(`Event #${idx + 1}: missing ts`);
    if (!event.source || typeof event.source !== "string") throw new Error(`Event #${idx + 1}: missing source`);
    if (!event.kind || typeof event.kind !== "string") throw new Error(`Event #${idx + 1}: missing kind`);
    if (!EVENT_KINDS.has(event.kind as EventKind)) throw new Error(`Event #${idx + 1}: unknown kind ${event.kind}`);
    if (!event.payload || typeof event.payload !== "object") throw new Error(`Event #${idx + 1}: missing payload`);

    return event as MemoryEvent;
  });
}

function buildSummary(events: MemoryEvent[], charBudget: number): Summary {
  const byKind = Object.fromEntries([...EVENT_KINDS].sort().map((k) => [k, 0]));
  for (const event of events) byKind[event.kind] = (byKind[event.kind] || 0) + 1;

  const changedFiles = events
    .filter((e) => e.kind === "code.files.changed")
    .flatMap((e) => ((e.payload.files as string[] | undefined) ?? []));

  const changedAreas = Array.from(new Set(changedFiles.map(topDir))).sort();

  const failingChecks = events
    .filter((e) => e.kind === "check.run.result")
    .filter((e) => {
      const status = String(e.payload.status ?? "").toLowerCase();
      return status === "fail" || status === "failed" || status === "error";
    })
    .map((e) => ({
      name: String(e.payload.name ?? "unknown-check"),
      files: (((e.payload.files as string[] | undefined) ?? []).map(normalizeRel)).sort(),
    }));

  const manualOverride = [...events]
    .reverse()
    .find((e) => e.kind === "focus.override.manual" || e.kind === "user.command.goal_set");

  const explicitIntent = [...events]
    .reverse()
    .find((e) => e.kind === "user.intent.explicit");

  const selectedIntent = (() => {
    if (manualOverride) {
      const label = String(manualOverride.payload.focus ?? manualOverride.payload.goal ?? "manual focus");
      return { label, confidence: 0.95, source: "manual_override" as const };
    }
    if (explicitIntent) {
      const label = String(explicitIntent.payload.intent ?? explicitIntent.payload.goal ?? "explicit intent");
      return { label, confidence: 0.85, source: "explicit_intent" as const };
    }
    if (changedAreas.length > 0) {
      return { label: `Work on ${changedAreas[0]}`, confidence: 0.6, source: "changed_area" as const };
    }
    return { label: "Unspecified", confidence: 0.2, source: "fallback" as const };
  })();

  const topRisks = failingChecks.slice(0, 3).map((check) => ({
    type: "logic_regression",
    impact: 0.7,
    confidence: 0.8,
    evidence: [check.name, ...check.files].slice(0, 4),
    nextStep: `Fix failing check: ${check.name}`,
  }));

  const lines = [
    "## SASU Mission Brief",
    `Intent: ${selectedIntent.label} (${selectedIntent.confidence.toFixed(2)})`,
    `Active focus: ${changedAreas.slice(0, 3).join(", ") || "(none detected)"}`,
    "Recent evidence:",
    `- changed areas: ${changedAreas.join(", ") || "(none)"}`,
    `- failing checks: ${failingChecks.map((c) => c.name).join(", ") || "(none)"}`,
    "Top risks:",
    ...(topRisks.length > 0
      ? topRisks.map((risk, i) => `${i + 1}) ${risk.type} — ${risk.nextStep}`)
      : ["1) none" as const]),
    "Next validation step:",
    `- ${failingChecks[0] ? `Run ${failingChecks[0].name} and verify touched files.` : "Run targeted checks for changed files."}`,
  ];

  let brief = lines.join("\n");
  if (brief.length > charBudget) {
    brief = `${brief.slice(0, charBudget).trimEnd()}\n... [truncated]`;
  }

  return {
    totalEvents: events.length,
    byKind,
    selectedIntent,
    changedAreas,
    failingChecks,
    topRisks,
    brief,
  };
}

function stableJson(value: unknown): string {
  return `${JSON.stringify(value, null, 2)}\n`;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const cwd = process.cwd();
  const fixturePath = path.resolve(cwd, args.fixture);
  const snapshotPath = path.resolve(cwd, args.snapshot);

  const fixtureRaw = await readFile(fixturePath, "utf8");
  const events = validateEvents(JSON.parse(fixtureRaw));
  const summary = buildSummary(events, args.charBudget);

  if (args.updateSnapshot) {
    await writeFile(snapshotPath, stableJson(summary), "utf8");
    console.log(`Updated snapshot: ${path.relative(cwd, snapshotPath)}`);
    return;
  }

  const expectedRaw = await readFile(snapshotPath, "utf8");
  const expected = JSON.parse(expectedRaw);
  const actualJson = stableJson(summary);
  const expectedJson = stableJson(expected);

  if (actualJson !== expectedJson) {
    console.error("Snapshot mismatch.");
    console.error("Run with --update-snapshot if change is intentional.");
    const outPath = path.resolve(cwd, "tests/fixtures/memory/actual-summary.json");
    await writeFile(outPath, actualJson, "utf8");
    console.error(`Wrote actual summary: ${path.relative(cwd, outPath)}`);
    process.exit(1);
  }

  console.log(`Replay OK: ${events.length} events, ${summary.failingChecks.length} failing checks, intent=${summary.selectedIntent.label}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
