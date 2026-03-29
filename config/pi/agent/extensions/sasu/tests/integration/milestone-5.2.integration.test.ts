import { describe, expect, it, mock } from "bun:test";
import { execFile } from "node:child_process";
import { mkdir, writeFile } from "node:fs/promises";
import { promisify } from "node:util";
import { ingestEvent } from "../../src/memory/ingest";
import { createMemoryStore } from "../../src/memory/store";
import { saveSession } from "../../src/storage";
import { withTempProject } from "../memory/test-helpers";

const execFileAsync = promisify(execFile);

mock.module("@mariozechner/pi-coding-agent", () => ({
  DynamicBorder: ({ children }: any) => children,
}));

mock.module("@mariozechner/pi-tui", () => ({
  Key: {
    UpArrow: "UpArrow",
    DownArrow: "DownArrow",
    Escape: "Escape",
    Enter: "Enter",
  },
  SelectList: (_props: any) => null,
  Text: (_props: any) => null,
  matchesKey: () => false,
}));

const { default: sasu } = await import("../../index");

type SentMessage = {
  message: any;
  options?: any;
};

class FakePi {
  private readonly commands = new Map<
    string,
    { handler: (args: string, ctx: any) => Promise<void> | void }
  >();
  private readonly listeners = new Map<
    string,
    Array<(event: any, ctx: any) => Promise<void> | void>
  >();
  public readonly sentMessages: SentMessage[] = [];
  public readonly sentUserMessages: Array<{ content: string; options?: any }> = [];
  private activeTools = ["read", "bash", "write"];
  private execCwd = process.cwd();

  registerCommand(
    name: string,
    command: { handler: (args: string, ctx: any) => Promise<void> | void },
  ) {
    this.commands.set(name, command);
  }

  on(eventName: string, handler: (event: any, ctx: any) => Promise<void> | void) {
    const existing = this.listeners.get(eventName) ?? [];
    existing.push(handler);
    this.listeners.set(eventName, existing);
  }

  sendMessage(message: any, options?: any) {
    this.sentMessages.push({ message, options });
  }

  sendUserMessage(content: string, options?: any) {
    this.sentUserMessages.push({ content, options });
  }

  getActiveTools(): string[] {
    return [...this.activeTools];
  }

  setActiveTools(tools: string[]) {
    this.activeTools = [...tools];
  }

  async exec(command: string, args: string[], options?: { timeout?: number }) {
    try {
      const { stdout, stderr } = await execFileAsync(command, args, {
        cwd: this.execCwd,
        timeout: options?.timeout,
        maxBuffer: 5 * 1024 * 1024,
      });
      return { stdout, stderr, code: 0, killed: false };
    } catch (error: any) {
      return {
        stdout: error?.stdout ?? "",
        stderr: error?.stderr ?? error?.message ?? "",
        code: typeof error?.code === "number" ? error.code : 1,
        killed: Boolean(error?.killed),
      };
    }
  }

  async runCommand(name: string, args: string, ctx: any): Promise<void> {
    const command = this.commands.get(name);
    if (!command) throw new Error(`Command not registered: ${name}`);
    this.execCwd = ctx.cwd;
    await command.handler(args, ctx);
  }

  async emit(eventName: string, event: any, ctx: any): Promise<void> {
    const handlers = this.listeners.get(eventName) ?? [];
    this.execCwd = ctx.cwd;
    for (const handler of handlers) {
      await handler(event, ctx);
    }
  }
}

function createCtx(cwd: string, input?: { idle?: boolean; hasUI?: boolean; sessionId?: string }) {
  let idle = input?.idle ?? true;
  const hasUI = input?.hasUI ?? true;
  const selectQueue: string[] = [];
  const inputQueue: Array<string | undefined> = [];
  const notifications: Array<{ message: string; level?: string }> = [];

  const ctx = {
    cwd,
    hasUI,
    sessionId: input?.sessionId ?? "test-session",
    isIdle: () => idle,
    ui: {
      notify: (message: string, level?: string) => {
        notifications.push({ message, level });
      },
      select: async (_prompt: string, options: string[]) => {
        if (selectQueue.length > 0) return selectQueue.shift();
        return options[0];
      },
      input: async (_prompt: string, placeholder?: string) => {
        if (inputQueue.length > 0) return inputQueue.shift();
        return placeholder;
      },
      custom: async <T>(_render: any): Promise<T | undefined> => undefined,
    },
  };

  return {
    ctx,
    notifications,
    queueSelect: (value: string) => selectQueue.push(value),
    queueInput: (value?: string) => inputQueue.push(value),
    setIdle: (value: boolean) => {
      idle = value;
    },
  };
}

function findLastMessageByType(
  messages: SentMessage[],
  customType: string,
): SentMessage | undefined {
  for (let i = messages.length - 1; i >= 0; i -= 1) {
    if (messages[i]?.message?.customType === customType) return messages[i];
  }
  return undefined;
}

async function feedbackCount(dbPath: string): Promise<number> {
  const { stdout } = await execFileAsync("sqlite3", [dbPath, "SELECT COUNT(1) FROM feedback;"]);
  return Number(stdout.trim() || "0") || 0;
}

describe("milestone 5.2 integration", () => {
  it("/sasu-review idle path uses mission brief", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      await saveSession(cwd, {
        version: 1,
        projectGoal: "Ship memory v0 safely",
        projectGoalSource: "test",
      });

      const store = await createMemoryStore(cwd);
      await ingestEvent(store, {
        projectRoot: cwd,
        source: "sasu",
        kind: "focus.override.manual",
        payload: { focus: "Review memory reducers" },
        ts: "2026-03-05T08:00:00.000Z",
      });

      const { ctx } = createCtx(cwd, { idle: true, hasUI: true });
      await pi.runCommand("sasu-review", "", ctx);

      const request = findLastMessageByType(pi.sentMessages, "sasu-review-request");
      expect(request).toBeDefined();
      expect(request?.options?.triggerTurn).toBe(true);
      expect(request?.options?.deliverAs).toBeUndefined();

      const prompt = String(request?.message?.content ?? "");
      expect(prompt).toContain("## SASU Mission Brief");
      expect(prompt).toContain("Active focus: Review memory reducers");
      expect(prompt).toContain("Active review focus source: memory.active_focus");
    });
  });

  it("/sasu-review follow-up path uses mission brief", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      await saveSession(cwd, {
        version: 1,
        projectGoal: "Ship memory v0 safely",
        projectGoalSource: "test",
      });

      const store = await createMemoryStore(cwd);
      await ingestEvent(store, {
        projectRoot: cwd,
        source: "sasu",
        kind: "focus.override.manual",
        payload: { focus: "Follow-up queue behavior" },
        ts: "2026-03-05T08:10:00.000Z",
      });

      const { ctx } = createCtx(cwd, { idle: false, hasUI: true });
      await pi.runCommand("sasu-review", "", ctx);

      const request = findLastMessageByType(pi.sentMessages, "sasu-review-request");
      expect(request).toBeDefined();
      expect(request?.options?.triggerTurn).toBe(true);
      expect(request?.options?.deliverAs).toBe("followUp");

      const prompt = String(request?.message?.content ?? "");
      expect(prompt).toContain("## SASU Mission Brief");
      expect(prompt).toContain("Active focus: Follow-up queue behavior");
      expect(prompt).toContain("Active review focus source: memory.active_focus");
    });
  });

  it("busy/queue semantics unchanged for review flow", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      await saveSession(cwd, {
        version: 1,
        projectGoal: "Protect review lifecycle",
        projectGoalSource: "test",
      });

      const { ctx, notifications } = createCtx(cwd, { idle: false, hasUI: true });
      await pi.runCommand("sasu-review", "", ctx);
      await pi.runCommand("sasu-review", "", ctx);

      const requestCount = pi.sentMessages.filter(
        (entry) => entry.message?.customType === "sasu-review-request",
      ).length;
      expect(requestCount).toBe(1);
      expect(notifications.some((entry) => entry.message.includes("already waiting"))).toBe(true);

      await pi.emit(
        "agent_end",
        { messages: [{ role: "assistant", content: "queued review response" }] },
        ctx,
      );

      const store = await createMemoryStore(cwd);
      let completed = await store.queryEvents({
        projectRoot: cwd,
        kinds: ["agent.review.completed"],
        limit: 10,
      });
      expect(completed).toHaveLength(0);

      await pi.emit(
        "agent_end",
        { messages: [{ role: "assistant", content: "final review response" }] },
        ctx,
      );

      completed = await store.queryEvents({
        projectRoot: cwd,
        kinds: ["agent.review.completed"],
        limit: 10,
      });
      expect(completed).toHaveLength(1);
    });
  });

  it("/sasu-suggest plus suggestion actions write feedback", async () => {
    await withTempProject(async (cwd) => {
      await mkdir(`${cwd}/src`, { recursive: true });
      await writeFile(`${cwd}/src/app.ts`, "export const app = true;\n", "utf8");

      const pi = new FakePi();
      sasu(pi as any);

      await saveSession(cwd, {
        version: 1,
        projectGoal: "Find right files quickly",
        projectGoalSource: "test",
      });

      const { ctx, queueSelect } = createCtx(cwd, { idle: true, hasUI: true });
      queueSelect("Skip for now");

      await pi.runCommand("sasu-suggest", "", ctx);
      const suggestRequest = findLastMessageByType(pi.sentMessages, "sasu-suggestion-request");
      expect(suggestRequest).toBeDefined();

      await pi.emit(
        "agent_end",
        {
          messages: [
            {
              role: "assistant",
              content: "1. OPEN src/app.ts — Start from application entrypoint",
            },
          ],
        },
        ctx,
      );

      const store = await createMemoryStore(cwd);
      const generated = await store.queryEvents({
        projectRoot: cwd,
        kinds: ["agent.suggestion.generated"],
        limit: 10,
      });
      const actions = await store.queryEvents({
        projectRoot: cwd,
        kinds: ["user.suggestion.action"],
        limit: 10,
      });
      expect(generated).toHaveLength(1);
      expect(actions).toHaveLength(1);
      expect(actions[0]?.payload?.action).toBe("ignored");

      expect(await feedbackCount(store.getDbPath())).toBe(1);
    });
  });

  it("/sasu-review works without manual goal setting and includes explicit evidence refs", async () => {
    await withTempProject(async (cwd) => {
      await writeFile(
        `${cwd}/README.md`,
        "# Smoke Project\n\n## Goal\nShip memory-driven review loop without manual goal commands.\n",
        "utf8",
      );

      const pi = new FakePi();
      sasu(pi as any);

      const store = await createMemoryStore(cwd);
      await store.upsertWorkingState("changed_areas", {
        paths: ["src/memory/brief.ts", "src/review.ts"],
        updatedAt: "2026-03-05T09:00:00.000Z",
      });
      await store.upsertWorkingState("last_checks", {
        failing: [
          { name: "bun test tests/memory", files: ["src/memory/brief.ts"], status: "failed" },
        ],
        passing: [],
        updatedAt: "2026-03-05T09:00:00.000Z",
      });

      const { ctx } = createCtx(cwd, { idle: true, hasUI: false });
      await pi.runCommand("sasu-review", "", ctx);

      const request = findLastMessageByType(pi.sentMessages, "sasu-review-request");
      expect(request).toBeDefined();

      const prompt = String(request?.message?.content ?? "");
      expect(prompt).toContain("## SASU Mission Brief");
      expect(prompt).toContain("Evidence refs (top-K):");
      expect(prompt).toContain("- files: src/memory/brief.ts");
      expect(prompt).toContain("- checks: bun test tests/memory");
      expect(prompt).toContain("Project goal source: README.md");
    });
  });

  it("/sasu-memory-* commands are available and usable", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      const store = await createMemoryStore(cwd);
      await ingestEvent(store, {
        projectRoot: cwd,
        source: "sasu",
        kind: "user.command.review",
        payload: { rawArgs: "", intentProvided: false },
        ts: "2026-03-05T10:00:00.000Z",
      });

      const { ctx, notifications } = createCtx(cwd, { idle: true, hasUI: false });

      await pi.runCommand("sasu-memory-status", "", ctx);
      const status = findLastMessageByType(pi.sentMessages, "sasu-memory-status");
      expect(status).toBeDefined();
      expect(String(status?.message?.content ?? "")).toContain("## SASU memory status");
      expect(String(status?.message?.content ?? "")).toContain("Total events: 1");

      await pi.runCommand("sasu-memory-tail", "20", ctx);
      const tail = findLastMessageByType(pi.sentMessages, "sasu-memory-tail");
      expect(tail).toBeDefined();
      expect(String(tail?.message?.content ?? "")).toContain("user.command.review");

      await pi.runCommand("sasu-memory-reset", "--yes", ctx);
      expect(notifications.some((entry) => entry.message.includes("reset complete"))).toBe(true);
      expect(await store.getEventTotalCount({ projectRoot: cwd })).toBe(0);
    });
  });

  it("/sasu-memory-ingest-nvim enforces phase-1 feeder contract and writes via ingestion pipeline", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      const { ctx, notifications } = createCtx(cwd, { idle: true, hasUI: false });

      await pi.runCommand(
        "sasu-memory-ingest-nvim",
        JSON.stringify({
          source: "nvim",
          kind: "code.files.changed",
          payload: {
            origin: "nvim.buf_write",
            files: ["src/memory/brief.ts"],
            reason: "save",
          },
          projectRoot: cwd,
          ts: "2026-03-06T09:00:00.000Z",
        }),
        ctx,
      );

      const ingestMessage = findLastMessageByType(pi.sentMessages, "sasu-memory-ingest-nvim");
      expect(ingestMessage).toBeDefined();
      expect(String(ingestMessage?.message?.content ?? "")).toContain(
        "## SASU memory ingest (nvim)",
      );

      const store = await createMemoryStore(cwd);
      const changedEvents = await store.queryEvents({
        projectRoot: cwd,
        kinds: ["code.files.changed"],
        limit: 10,
      });
      expect(changedEvents.some((event) => event.source === "nvim")).toBe(true);

      const changedAreas = await store.getWorkingState("changed_areas");
      expect(changedAreas?.paths).toContain("src/memory/brief.ts");

      await pi.runCommand(
        "sasu-memory-ingest-nvim",
        JSON.stringify({
          source: "nvim",
          kind: "code.files.changed",
          payload: {
            origin: "nvim.buf_write",
            files: ["/absolute/path.ts"],
            reason: "save",
          },
          projectRoot: cwd,
          ts: "2026-03-06T09:01:00.000Z",
        }),
        ctx,
      );
      expect(
        notifications.some((entry) => entry.message.includes("Failed to ingest nvim feeder event")),
      ).toBe(true);

      await pi.runCommand("sasu-memory-tail", "20 --kind code.files.changed", ctx);
      const tail = findLastMessageByType(pi.sentMessages, "sasu-memory-tail");
      expect(String(tail?.message?.content ?? "")).toContain("| code.files.changed | nvim |");
    });
  });

  it("/sasu-memory-ingest-nvim-save ingests BufWritePost signal with relative path and dedupes repeats", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      await saveSession(cwd, {
        version: 1,
        projectGoal: "Keep changed areas in sync from editor saves",
        projectGoalSource: "test",
      });

      const { ctx, notifications } = createCtx(cwd, { idle: true, hasUI: false });
      const filePath = `${cwd}/src/memory/brief.ts`;

      await pi.runCommand(
        "sasu-memory-ingest-nvim-save",
        JSON.stringify({ file: filePath, ts: "2026-03-06T10:00:00.000Z" }),
        ctx,
      );
      await pi.runCommand(
        "sasu-memory-ingest-nvim-save",
        JSON.stringify({ file: filePath, ts: "2026-03-06T10:00:05.000Z" }),
        ctx,
      );

      const ingestMessage = findLastMessageByType(pi.sentMessages, "sasu-memory-ingest-nvim-save");
      expect(ingestMessage).toBeDefined();
      expect(String(ingestMessage?.message?.content ?? "")).toContain("code.files.changed");

      const store = await createMemoryStore(cwd);
      const changedEvents = await store.queryEvents({
        projectRoot: cwd,
        kinds: ["code.files.changed"],
        limit: 20,
      });
      const nvimSaveEvents = changedEvents.filter((event) => {
        const files = Array.isArray(event.payload.files)
          ? event.payload.files.filter((value): value is string => typeof value === "string")
          : [];
        return (
          event.source === "nvim" &&
          event.payload.origin === "nvim.buf_write" &&
          files.includes("src/memory/brief.ts")
        );
      });
      expect(nvimSaveEvents).toHaveLength(1);

      const changedAreas = await store.getWorkingState("changed_areas");
      expect(changedAreas?.paths).toContain("src/memory/brief.ts");

      await pi.runCommand("sasu-review", "", ctx);
      const request = findLastMessageByType(pi.sentMessages, "sasu-review-request");
      expect(String(request?.message?.content ?? "")).toContain("- files: src/memory/brief.ts");

      await pi.runCommand("sasu-memory-ingest-nvim-save", "./../outside.ts", ctx);
      expect(
        notifications.some((entry) => entry.message.includes("Failed to ingest nvim save signal")),
      ).toBe(true);
    });
  });

  it("/sasu-goal manual override blocks low-confidence auto intent replacement", async () => {
    await withTempProject(async (cwd) => {
      const pi = new FakePi();
      sasu(pi as any);

      await saveSession(cwd, {
        version: 1,
        projectGoal: "Preserve user-driven focus",
        projectGoalSource: "test",
      });

      const context = createCtx(cwd, { idle: true, hasUI: false });
      await pi.runCommand("sasu-goal", "Manual focus lock", context.ctx);

      const store = await createMemoryStore(cwd);
      await store.upsertWorkingState("intent_hypotheses", {
        hypotheses: [
          { label: "auto low-confidence guess", confidence: 0.2, evidence: ["fallback"] },
        ],
        selected: { label: "auto low-confidence guess", confidence: 0.2, source: "fallback" },
        needsClarification: true,
      });

      await pi.runCommand("sasu-review", "", context.ctx);
      const request = findLastMessageByType(pi.sentMessages, "sasu-review-request");
      expect(request).toBeDefined();

      const prompt = String(request?.message?.content ?? "");
      expect(prompt).toContain(
        "Memory-selected intent: Manual focus lock (0.95 via manual_override)",
      );
      expect(prompt).toContain("Needs clarification: no");
      expect(prompt).not.toContain("auto low-confidence guess");
    });
  });
});
