import type { IntentInferenceState, MissionBrief, RiskItem, WorkingStateByKey } from "./types";

const DEFAULT_BRIEF_TOKEN_CAP = 1800;
const DEFAULT_BRIEF_CHAR_CAP = DEFAULT_BRIEF_TOKEN_CAP * 4;
const DEFAULT_TOP_EVIDENCE_REFS = 8;
const TRUNCATED_SUFFIX = "\n... [truncated]";

function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function normalizeRef(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const normalized = value.replace(/\s+/g, " ").trim();
  return normalized.length > 0 ? normalized : null;
}

function summarizeList(values: string[], maxItems: number): string {
  if (values.length === 0) return "(none)";
  const unique = Array.from(new Set(values));
  const top = unique.slice(0, maxItems);
  const remaining = unique.length - top.length;
  return `${top.join(", ")}${remaining > 0 ? ` (+${remaining} more)` : ""}`;
}

function applyCharBudget(text: string, maxChars: number): string {
  if (text.length <= maxChars) return text;
  const available = maxChars - TRUNCATED_SUFFIX.length;
  if (available <= 0) return TRUNCATED_SUFFIX.slice(0, maxChars);
  return `${text.slice(0, available).trimEnd()}${TRUNCATED_SUFFIX}`;
}

function buildRiskLines(risks: RiskItem[]): string[] {
  if (risks.length === 0) return ["1) none"];
  return risks.slice(0, 3).map((risk, index) => `${index + 1}) ${risk.type} — ${risk.nextStep}`);
}

function riskPriority(risk: RiskItem): number {
  return clamp(risk.impact, 0, 1) * clamp(risk.confidence, 0, 1);
}

function rankEvidenceRefs(input: {
  workingState: Partial<WorkingStateByKey>;
  topK: number;
}): string[] {
  const scores = new Map<string, number>();

  const addScore = (ref: unknown, score: number) => {
    const normalized = normalizeRef(ref);
    if (!normalized) return;
    scores.set(normalized, (scores.get(normalized) ?? 0) + score);
  };

  for (const path of input.workingState.changed_areas?.paths ?? []) {
    addScore(path, 1.4);
  }

  for (const check of input.workingState.last_checks?.failing ?? []) {
    addScore(`check:${check.name}`, 4.0);
    for (const file of check.files ?? []) {
      addScore(file, 2.4);
    }
  }

  for (const risk of input.workingState.open_risks ?? []) {
    const riskWeight = riskPriority(risk);
    for (const evidenceRef of risk.evidence ?? []) {
      addScore(evidenceRef, 1 + riskWeight * 3);
    }
  }

  for (const evidenceRef of input.workingState.last_review_summary?.evidence ?? []) {
    addScore(evidenceRef, 1.8);
  }

  return [...scores.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
    .slice(0, input.topK)
    .map(([ref]) => ref);
}

function splitEvidenceRefs(evidenceRefs: string[]): { fileRefs: string[]; checkRefs: string[] } {
  const fileRefs: string[] = [];
  const checkRefs: string[] = [];

  for (const ref of evidenceRefs) {
    if (ref.startsWith("check:")) {
      checkRefs.push(ref.slice("check:".length));
      continue;
    }
    fileRefs.push(ref);
  }

  return { fileRefs, checkRefs };
}

export function resolveIntentContext(input: {
  workingState: Partial<WorkingStateByKey>;
  fallbackIntent?: string;
}): IntentInferenceState {
  const state = input.workingState.intent_hypotheses;
  const activeFocus = input.workingState.active_focus;
  const fallback = input.fallbackIntent?.trim();

  if (activeFocus?.label?.trim()) {
    const confidence = activeFocus.locked ? 0.95 : 0.75;
    return {
      hypotheses: [{ label: activeFocus.label, confidence, evidence: [activeFocus.source] }],
      selected: {
        label: activeFocus.label,
        confidence,
        source: activeFocus.locked ? "manual_override" : activeFocus.source,
      },
      needsClarification: false,
    };
  }

  if (state?.selected) {
    const confidence = clamp(state.selected.confidence, 0, 1);
    return {
      hypotheses: Array.isArray(state.hypotheses) ? state.hypotheses : [],
      selected: {
        label: state.selected.label,
        confidence,
        source: state.selected.source,
      },
      needsClarification: confidence < 0.55,
    };
  }

  if (fallback && fallback.length > 0) {
    return {
      hypotheses: [{ label: fallback, confidence: 0.4, evidence: ["fallback"] }],
      selected: { label: fallback, confidence: 0.4, source: "fallback" },
      needsClarification: true,
    };
  }

  return {
    hypotheses: [],
    selected: { label: "Unspecified", confidence: 0.2, source: "fallback" },
    needsClarification: true,
  };
}

export function buildMissionBrief(input: {
  workingState: Partial<WorkingStateByKey>;
  fallbackIntent?: string;
  maxChars?: number;
  maxEvidenceRefs?: number;
}): MissionBrief {
  const resolvedIntent = resolveIntentContext({
    workingState: input.workingState,
    fallbackIntent: input.fallbackIntent,
  });

  const selectedIntent = resolvedIntent.selected ?? {
    label: "Unspecified",
    confidence: 0.2,
    source: "fallback",
  };

  const changedAreas = input.workingState.changed_areas?.paths ?? [];
  const failingChecksDetailed = input.workingState.last_checks?.failing ?? [];
  const failingChecks = failingChecksDetailed.map((check) => check.name);
  const topRisks = [...(input.workingState.open_risks ?? [])]
    .sort((a, b) => riskPriority(b) - riskPriority(a))
    .slice(0, 3);

  const maxEvidenceRefs = clamp(input.maxEvidenceRefs ?? DEFAULT_TOP_EVIDENCE_REFS, 1, 50);
  const evidenceRefs = rankEvidenceRefs({
    workingState: input.workingState,
    topK: maxEvidenceRefs,
  });
  const { fileRefs, checkRefs } = splitEvidenceRefs(evidenceRefs);

  const firstCheckRef = checkRefs[0] ?? failingChecks[0];
  const nextValidationStep = firstCheckRef
    ? `Run ${firstCheckRef} and verify touched files.`
    : "Run targeted checks for changed files.";

  const lines = [
    "## SASU Mission Brief",
    `Intent: ${selectedIntent.label} (${selectedIntent.confidence.toFixed(2)})`,
    `Active focus: ${input.workingState.active_focus?.label ?? "(none detected)"}`,
    "Recent evidence:",
    `- changed areas: ${summarizeList(changedAreas, 12)}`,
    `- failing checks: ${summarizeList(failingChecks, 8)}`,
    "Evidence refs (top-K):",
    `- files: ${summarizeList(fileRefs, maxEvidenceRefs)}`,
    `- checks: ${summarizeList(checkRefs, maxEvidenceRefs)}`,
    "Top risks:",
    ...buildRiskLines(topRisks),
    "Next validation step:",
    `- ${nextValidationStep}`,
  ];

  const maxChars = clamp(input.maxChars ?? DEFAULT_BRIEF_CHAR_CAP, 300, 40_000);
  const markdown = applyCharBudget(lines.join("\n"), maxChars);

  return {
    intent: selectedIntent,
    activeFocus: input.workingState.active_focus?.label,
    recentEvidence: {
      changedAreas: changedAreas.slice(0, 20),
      failingChecks: failingChecks.slice(0, 20),
    },
    evidenceRefs,
    topRisks,
    nextValidationStep,
    markdown,
    estimatedTokens: estimateTokens(markdown),
  };
}
