import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import type { ExecResult } from "./types";

export async function runExec(
  pi: ExtensionAPI,
  command: string,
  args: string[],
  timeout?: number,
): Promise<ExecResult> {
  const result = await pi.exec(command, args, timeout ? { timeout } : undefined);
  return {
    stdout: result.stdout || "",
    stderr: result.stderr || "",
    code: result.code ?? 1,
    killed: result.killed,
  };
}
