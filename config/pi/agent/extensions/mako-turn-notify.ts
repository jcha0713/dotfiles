import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import * as path from "node:path";

// Store tool calls for the current turn
interface ToolCallInfo {
  toolName: string;
  args: Record<string, unknown>;
}

const currentTurnTools = new Map<string, ToolCallInfo>();

// Helper to truncate and format command strings
function truncate(str: string, maxLen: number): string {
  if (str.length <= maxLen) return str;
  return str.slice(0, maxLen - 3) + "...";
}

// Helper to extract project name from cwd
function getProjectName(cwd: string): string {
  const base = path.basename(cwd);
  // Handle home directory specially
  if (cwd === process.env.HOME || cwd === "~") {
    return "~";
  }
  return base || cwd;
}

// Format a tool call for display
function formatToolCall(
  toolName: string,
  args: Record<string, unknown>,
  maxLen: number = 50,
): string {
  // For bash tool, show the command
  if (toolName === "bash" && args?.command) {
    return `bash: ${truncate(String(args.command), maxLen)}`;
  }

  // For read tool, show the path
  if (toolName === "read" && args?.path) {
    return `read: ${truncate(String(args.path), maxLen)}`;
  }

  // For write tool, show the path
  if (toolName === "write" && args?.path) {
    return `write: ${truncate(String(args.path), maxLen)}`;
  }

  // For edit tool, show the path
  if (toolName === "edit" && args?.path) {
    return `edit: ${truncate(String(args.path), maxLen)}`;
  }

  // For grep tool, show the pattern
  if (toolName === "grep" && args?.pattern) {
    return `grep: ${truncate(String(args.pattern), maxLen)}`;
  }

  // For find tool, show the pattern
  if (toolName === "find" && args?.pattern) {
    return `find: ${truncate(String(args.pattern), maxLen)}`;
  }

  // For ls tool, show the path
  if (toolName === "ls" && args?.path) {
    return `ls: ${truncate(String(args.path), maxLen)}`;
  }

  // Default: just show tool name
  return toolName;
}

export default function (pi: ExtensionAPI) {
  // Track tool execution starts to capture the command
  pi.on("tool_execution_start", async (event, ctx) => {
    currentTurnTools.set(event.toolCallId, {
      toolName: event.toolName,
      args: event.args,
    });
  });

  pi.on("turn_end", async (event, ctx) => {
    const toolCount = event.toolResults?.length ?? 0;
    const projectName = getProjectName(ctx.cwd);

    // Build notification message from tracked tool calls
    let message: string;
    if (toolCount === 0) {
      message = "Turn complete (no tools used)";
    } else {
      const toolList = event.toolResults
        ?.map((result) => {
          const toolCall = currentTurnTools.get(result.toolCallId);
          if (toolCall) {
            return formatToolCall(toolCall.toolName, toolCall.args);
          }
          return result.toolName;
        })
        .join("\n");

      if (toolCount === 1) {
        message = `${toolList}`;
      } else {
        message = `(${toolCount} tools)\n${toolList}`;
      }
    }

    // Clear tracked tools for next turn
    currentTurnTools.clear();

    // Send notification via mako
    try {
      await pi.exec("makoctl", ["dismiss", "--all"], { timeout: 1000 }).catch(() => {});
      await pi.exec(
        "notify-send",
        [
          `Pi [${projectName}]`,
          message,
          "--app-name=pi",
          "--urgency=normal",
          "--expire-time=20000",
        ],
        { timeout: 5000 },
      );
    } catch {
      // Silently fail if notification doesn't work
    }
  });

  // Optional: notify on agent_end as well (full prompt completion)
  pi.on("agent_end", async (_event, ctx) => {
    const projectName = getProjectName(ctx.cwd);
    try {
      await pi.exec(
        "notify-send",
        [
          `Pi [${projectName}]`,
          "Response complete",
          "--app-name=pi",
          "--urgency=low",
          "--expire-time=20000",
        ],
        { timeout: 5000 },
      );
    } catch {
      // Silently fail
    }
  });
}
