export type Nullable<T> = T | null;
export type OpenMode = "foreground" | "background";

export interface SuggestedFile {
	path: string;
	reason?: string;
}

export interface SessionData {
	version: number;
	projectGoal?: string;
	projectGoalSource?: string;
	sessionGoal?: string;
	sessionGoalSource?: string;
	sessionGoalUpdatedAt?: string;
	lastIntent?: string;
	lastReviewAt?: string;
	lastSuggestedFiles?: SuggestedFile[];
	lastSuggestionsUpdatedAt?: string;
	// Legacy fields (for migration in loadSession)
	goal?: string;
	goalSource?: string;
}

export interface ConfigData {
	checks?: string[];
	openCommand?: string;
	openMode?: OpenMode;
	maxSuggestions?: number;
}

export interface CheckResult {
	command: string;
	exitCode: number;
	stdout: string;
	stderr: string;
}

export interface GitContext {
	available: boolean;
	baseRef?: string;
	changedFiles: string[];
	untrackedFiles: string[];
	diff: string;
	note?: string;
}

export interface ExecResult {
	stdout: string;
	stderr: string;
	code: number;
	killed?: boolean;
}
