import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { MAX_CHECK_OUTPUT_CHARS } from "./constants";
import { runExec } from "./exec";
import { loadConfig } from "./storage";
import type { CheckResult } from "./types";
import { truncateText } from "./utils";

export async function runOptionalChecks(pi: ExtensionAPI, cwd: string): Promise<CheckResult[]> {
  const config = await loadConfig(cwd);
  const commands = (config.checks ?? []).map((c) => c.trim()).filter((c) => c.length > 0);
  if (commands.length === 0) return [];

  const results: CheckResult[] = [];
  for (const command of commands) {
    const result = await runExec(pi, "bash", ["-lc", command], 60_000);
    results.push({
      command,
      exitCode: result.code,
      stdout: truncateText(result.stdout, MAX_CHECK_OUTPUT_CHARS).text,
      stderr: truncateText(result.stderr, MAX_CHECK_OUTPUT_CHARS).text,
    });
  }

  return results;
}
