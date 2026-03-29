export type MemoryEventSource = "pi" | "sasu" | "nvim" | "git" | "check";

export type MemoryEventKind =
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

export type MemoryEventPayload = Record<string, unknown>;

export interface MemoryEvent {
  id: string;
  ts: string;
  projectRoot: string;
  sessionId?: string;
  source: MemoryEventSource;
  kind: MemoryEventKind;
  payload: MemoryEventPayload;
  fingerprint?: string;
}

export interface IntentHypothesis {
  label: string;
  confidence: number;
  evidence: string[];
}

export interface IntentInferenceState {
  hypotheses: IntentHypothesis[];
  selected?: {
    label: string;
    confidence: number;
    source: string;
  };
  needsClarification: boolean;
}

export interface ActiveFocusState {
  label: string;
  source: string;
  locked?: boolean;
  updatedAt?: string;
}

export interface ChangedAreasState {
  paths: string[];
  updatedAt?: string;
}

export interface LastChecksState {
  failing: Array<{ name: string; files: string[]; status?: string }>;
  passing: Array<{ name: string; files: string[]; status?: string }>;
  updatedAt?: string;
}

export interface LastReviewSummaryState {
  summary: string;
  evidence?: string[];
  updatedAt?: string;
}

export type RiskType =
  | "api_break"
  | "logic_regression"
  | "coverage_gap"
  | "migration_mismatch"
  | "perf"
  | "security";

export interface RiskItem {
  type: RiskType;
  impact: number;
  confidence: number;
  evidence: string[];
  nextStep: string;
}

export interface WorkingStateByKey {
  intent_hypotheses: IntentInferenceState;
  active_focus: ActiveFocusState;
  changed_areas: ChangedAreasState;
  open_risks: RiskItem[];
  last_checks: LastChecksState;
  last_review_summary: LastReviewSummaryState;
}

export type WorkingStateKey = keyof WorkingStateByKey;

export interface EpisodeRecord {
  id: string;
  startTs: string;
  endTs?: string;
  summary?: string;
  intent?: Record<string, unknown>;
  evidence?: Record<string, unknown>;
  outcome?: Record<string, unknown>;
}

export type FeedbackAction = "accepted" | "dismissed" | "ignored" | "edited";

export interface FeedbackRecord {
  id: string;
  ts: string;
  suggestionId?: string;
  action: FeedbackAction;
  context?: Record<string, unknown>;
}

export interface MissionBrief {
  intent: { label: string; confidence: number; source: string };
  activeFocus?: string;
  recentEvidence: {
    changedAreas: string[];
    failingChecks: string[];
  };
  evidenceRefs: string[];
  topRisks: RiskItem[];
  nextValidationStep: string;
  markdown: string;
  estimatedTokens?: number;
}

export interface MemoryEventQuery {
  projectRoot?: string;
  sessionId?: string;
  kinds?: MemoryEventKind[];
  sinceTs?: string;
  untilTs?: string;
  limit?: number;
  offset?: number;
}
