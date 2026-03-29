import { describe, expect, it } from "bun:test";
import {
  buildNvimBufWriteEnvelope,
  normalizeNvimFeederEnvelope,
  normalizeNvimFilePath,
} from "../../src/memory/feeder";

describe("memory/feeder", () => {
  it("accepts valid Neovim feeder envelope", () => {
    const normalized = normalizeNvimFeederEnvelope(
      {
        source: "nvim",
        kind: "code.files.changed",
        payload: {
          origin: "nvim.buf_write",
          files: ["./src/memory/brief.ts", "src/memory/brief.ts"],
          reason: "save",
        },
        projectRoot: "/tmp/project",
        ts: "2026-03-06T09:00:00.000Z",
      },
      "/tmp/project",
    );

    expect(normalized.source).toBe("nvim");
    expect(normalized.kind).toBe("code.files.changed");
    expect(normalized.projectRoot).toBe("/tmp/project");
    expect(normalized.payload.files).toEqual(["src/memory/brief.ts"]);
  });

  it("normalizes save file paths to project-relative shape", () => {
    expect(normalizeNvimFilePath("./src/memory/brief.ts", "/tmp/project")).toBe(
      "src/memory/brief.ts",
    );
    expect(normalizeNvimFilePath("/tmp/project/src/memory/brief.ts", "/tmp/project")).toBe(
      "src/memory/brief.ts",
    );
  });

  it("builds BufWritePost envelope with fixed nvim save payload", () => {
    const envelope = buildNvimBufWriteEnvelope({
      filePath: "/tmp/project/src/memory/brief.ts",
      projectRoot: "/tmp/project",
      ts: "2026-03-06T09:15:00.000Z",
    });

    expect(envelope).toEqual({
      source: "nvim",
      kind: "code.files.changed",
      payload: {
        origin: "nvim.buf_write",
        files: ["src/memory/brief.ts"],
        reason: "save",
      },
      projectRoot: "/tmp/project",
      ts: "2026-03-06T09:15:00.000Z",
      sessionId: undefined,
    });
  });

  it("rejects contract violations (source/projectRoot/ts)", () => {
    expect(() =>
      normalizeNvimFeederEnvelope(
        {
          source: "sasu",
          kind: "code.files.changed",
          payload: { files: ["src/memory/brief.ts"] },
          projectRoot: "/tmp/project",
          ts: "2026-03-06T09:00:00.000Z",
        },
        "/tmp/project",
      ),
    ).toThrow('source must be "nvim"');

    expect(() =>
      normalizeNvimFeederEnvelope(
        {
          source: "nvim",
          kind: "code.files.changed",
          payload: { files: ["src/memory/brief.ts"] },
          projectRoot: "/tmp/other",
          ts: "2026-03-06T09:00:00.000Z",
        },
        "/tmp/project",
      ),
    ).toThrow("projectRoot mismatch");

    expect(() =>
      normalizeNvimFeederEnvelope(
        {
          source: "nvim",
          kind: "code.files.changed",
          payload: { files: ["src/memory/brief.ts"] },
          projectRoot: "/tmp/project",
          ts: "not-a-timestamp",
        },
        "/tmp/project",
      ),
    ).toThrow("ts must be a valid timestamp");
  });

  it("rejects absolute paths and raw text payload keys", () => {
    expect(() =>
      normalizeNvimFeederEnvelope(
        {
          source: "nvim",
          kind: "code.files.changed",
          payload: { files: ["/tmp/project/src/memory/brief.ts"] },
          projectRoot: "/tmp/project",
          ts: "2026-03-06T09:00:00.000Z",
        },
        "/tmp/project",
      ),
    ).toThrow("project-relative");

    expect(() =>
      buildNvimBufWriteEnvelope({
        filePath: "/tmp/other/brief.ts",
        projectRoot: "/tmp/project",
      }),
    ).toThrow("project root");

    expect(() =>
      normalizeNvimFeederEnvelope(
        {
          source: "nvim",
          kind: "focus.override.manual",
          payload: {
            focus: "stabilize reducer wiring",
            text: "full buffer dump should be rejected",
          },
          projectRoot: "/tmp/project",
          ts: "2026-03-06T09:00:00.000Z",
        },
        "/tmp/project",
      ),
    ).toThrow("raw text/buffer payloads are forbidden");
  });
});
