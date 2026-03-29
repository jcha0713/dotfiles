import { mkdir, readFile, writeFile } from "node:fs/promises";
import * as path from "node:path";
import { CONFIG_FILE, SESSION_DIR, SESSION_FILE } from "./constants";
import type { ConfigData, Nullable, SessionData } from "./types";

async function loadJsonFile<T>(filePath: string): Promise<Nullable<T>> {
  try {
    const raw = await readFile(filePath, "utf8");
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

async function saveJsonFile(filePath: string, data: unknown): Promise<void> {
  await mkdir(path.dirname(filePath), { recursive: true });
  await writeFile(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
}

function getSessionPath(cwd: string): string {
  return path.join(cwd, SESSION_DIR, SESSION_FILE);
}

function getConfigPath(cwd: string): string {
  return path.join(cwd, SESSION_DIR, CONFIG_FILE);
}

export async function loadSession(cwd: string): Promise<SessionData> {
  const parsed = await loadJsonFile<SessionData>(getSessionPath(cwd));
  if (!parsed || typeof parsed !== "object") return { version: 1 };

  let projectGoal = typeof parsed.projectGoal === "string" ? parsed.projectGoal : undefined;
  let projectGoalSource =
    typeof parsed.projectGoalSource === "string" ? parsed.projectGoalSource : undefined;
  let sessionGoal = typeof parsed.sessionGoal === "string" ? parsed.sessionGoal : undefined;
  let sessionGoalSource =
    typeof parsed.sessionGoalSource === "string" ? parsed.sessionGoalSource : undefined;

  const legacyGoal = typeof parsed.goal === "string" ? parsed.goal : undefined;
  const legacyGoalSource = typeof parsed.goalSource === "string" ? parsed.goalSource : undefined;
  if (!projectGoal && !sessionGoal && legacyGoal?.trim()) {
    if (legacyGoalSource === "session-goal" || legacyGoalSource === "sasu-goal") {
      sessionGoal = legacyGoal;
      sessionGoalSource = legacyGoalSource;
    } else {
      projectGoal = legacyGoal;
      projectGoalSource = legacyGoalSource ?? "legacy-goal";
    }
  }

  return {
    version: 1,
    projectGoal,
    projectGoalSource,
    sessionGoal,
    sessionGoalSource,
    sessionGoalUpdatedAt: parsed.sessionGoalUpdatedAt,
    lastIntent: parsed.lastIntent,
    lastReviewAt: parsed.lastReviewAt,
    lastSuggestedFiles: Array.isArray(parsed.lastSuggestedFiles) ? parsed.lastSuggestedFiles : [],
    lastSuggestionsUpdatedAt: parsed.lastSuggestionsUpdatedAt,
  };
}

export async function saveSession(cwd: string, session: SessionData): Promise<void> {
  await saveJsonFile(getSessionPath(cwd), {
    version: 1,
    projectGoal: session.projectGoal,
    projectGoalSource: session.projectGoalSource,
    sessionGoal: session.sessionGoal,
    sessionGoalSource: session.sessionGoalSource,
    sessionGoalUpdatedAt: session.sessionGoalUpdatedAt,
    lastIntent: session.lastIntent,
    lastReviewAt: session.lastReviewAt,
    lastSuggestedFiles: Array.isArray(session.lastSuggestedFiles) ? session.lastSuggestedFiles : [],
    lastSuggestionsUpdatedAt: session.lastSuggestionsUpdatedAt,
  });
}

export async function loadConfig(cwd: string): Promise<ConfigData> {
  const parsed = await loadJsonFile<ConfigData>(getConfigPath(cwd));
  if (!parsed || typeof parsed !== "object") return {};
  const checks = Array.isArray(parsed.checks)
    ? parsed.checks.filter((v): v is string => typeof v === "string")
    : undefined;
  const openMode =
    parsed.openMode === "background"
      ? "background"
      : parsed.openMode === "foreground"
        ? "foreground"
        : undefined;
  const openCommand = typeof parsed.openCommand === "string" ? parsed.openCommand : undefined;
  const maxSuggestions =
    typeof parsed.maxSuggestions === "number" && parsed.maxSuggestions > 0
      ? parsed.maxSuggestions
      : undefined;
  return { checks, openCommand, openMode, maxSuggestions };
}
