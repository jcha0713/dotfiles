import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { MAX_DIFF_CHARS } from "./constants";
import { runExec } from "./exec";
import type { GitContext } from "./types";
import { truncateText } from "./utils";

export async function collectGitContext(pi: ExtensionAPI): Promise<GitContext> {
  const inside = await runExec(pi, "git", ["rev-parse", "--is-inside-work-tree"]);
  if (inside.code !== 0 || !inside.stdout.toLowerCase().includes("true")) {
    return {
      available: false,
      changedFiles: [],
      untrackedFiles: [],
      diff: "",
      note: "Not a git repository (or git unavailable).",
    };
  }

  let baseRef = "HEAD";
  const hasHead = await runExec(pi, "git", ["rev-parse", "--verify", "HEAD"]);
  if (hasHead.code !== 0) {
    const emptyTree = await runExec(pi, "git", ["hash-object", "-t", "tree", "/dev/null"]);
    baseRef = emptyTree.code === 0 ? emptyTree.stdout.trim() : "HEAD";
  }

  const changed = await runExec(pi, "git", ["diff", "--name-only", baseRef, "--"]);
  const untracked = await runExec(pi, "git", ["ls-files", "--others", "--exclude-standard"]);
  const diff = await runExec(
    pi,
    "git",
    ["diff", "--unified=3", "--no-ext-diff", baseRef, "--"],
    30_000,
  );

  const changedFiles = Array.from(
    new Set(
      changed.stdout
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.length > 0),
    ),
  );

  const untrackedFiles = Array.from(
    new Set(
      untracked.stdout
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.length > 0),
    ),
  );

  const truncatedDiff = truncateText(diff.stdout, MAX_DIFF_CHARS).text;

  return {
    available: true,
    baseRef,
    changedFiles,
    untrackedFiles,
    diff: truncatedDiff,
  };
}
