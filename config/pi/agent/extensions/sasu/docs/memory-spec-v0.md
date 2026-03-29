# SASU Memory System Spec v0

Status: Draft (research-based)  
Date: 2026-03-05  
Scope: `config/pi/agent/extensions/sasu`

## 1) Why this exists

SASU currently depends too much on manually set session goals. For ambient, always-on guidance, SASU needs a memory core that can:

- infer coder intent from evidence,
- preserve useful context across sessions,
- provide concise, high-signal review guidance,
- stay token-efficient.

This spec defines the v0 foundation.

---

## 2) Research synthesis (what we adopt)

### From `pi-brain`

- Keep **reasoning memory separate from code version control**.
- Use event/hook capture for continuity.
- Preserve distilled milestone snapshots.

### From `rho`

- Use **event-sourced local memory**.
- Use typed memory entries + dedup/tombstone semantics.
- Use strict **budgeted context building** before model calls.
- Add memory observability commands.

### From `momo`

- Keep door open for optional external semantic retrieval later.
- Do **not** make external memory service mandatory in v0.

### Design choice

Build a **local-first memory spine** in SASU now. External memory backends are optional Phase 2+.

---

## 3) Non-goals (v0)

- No always-on autonomous coding loop.
- No mandatory vector DB / hosted memory service.
- No heavy background summarization on every keystroke.
- No large dynamic system-prompt rewrites each turn.

---

## 4) Architecture (v0)

```text
Pi + SASU commands/hooks + (future) Neovim events
                    |
                    v
              Event Ingestor
                    |
                    v
             Memory Store (SQLite)
                    |
        +-----------+-----------+
        |                       |
        v                       v
 Working State Reducers    Episodic Distiller
        |                       |
        +-----------+-----------+
                    v
           Mission Brief Builder
                    |
                    v
            /sasu-review prompt
```

Core principle: **LLM is consumer of memory, not the memory system**.

---

## 5) Storage model

File: `.sasu/context.db` (SQLite)

### Tables

#### `events`

Append-only event log.

- `id TEXT PRIMARY KEY`
- `ts TEXT NOT NULL` (ISO timestamp)
- `project_root TEXT NOT NULL`
- `session_id TEXT`
- `source TEXT NOT NULL` (`pi`, `sasu`, `nvim`, `git`, `check`)
- `kind TEXT NOT NULL` (taxonomy below)
- `payload_json TEXT NOT NULL`
- `fingerprint TEXT` (dedup helper)

Indexes:

- `(project_root, ts DESC)`
- `(kind, ts DESC)`
- `(session_id, ts DESC)`

#### `working_state`

Current materialized state.

- `key TEXT PRIMARY KEY`
- `value_json TEXT NOT NULL`
- `updated_at TEXT NOT NULL`

Keys expected in v0:

- `intent_hypotheses`
- `active_focus`
- `changed_areas`
- `open_risks`
- `last_checks`
- `last_review_summary`

#### `episodes`

Session-loop summaries.

- `id TEXT PRIMARY KEY`
- `start_ts TEXT NOT NULL`
- `end_ts TEXT`
- `summary TEXT`
- `intent_json TEXT`
- `evidence_json TEXT`
- `outcome_json TEXT`

#### `feedback`

What guidance was accepted/ignored.

- `id TEXT PRIMARY KEY`
- `ts TEXT NOT NULL`
- `suggestion_id TEXT`
- `action TEXT NOT NULL` (`accepted`, `dismissed`, `ignored`, `edited`)
- `context_json TEXT`

---

## 6) Event taxonomy (v0)

- `user.command.review`
- `user.command.suggest`
- `user.command.goal_set`
- `user.intent.explicit`
- `code.git.snapshot`
- `code.files.changed`
- `check.run.result`
- `agent.review.requested`
- `agent.review.completed`
- `agent.suggestion.generated`
- `user.suggestion.action`
- `focus.override.manual`

All events include minimal payload + evidence references (file paths/check IDs).

---

## 7) Ingestion points in existing SASU

Integrate without breaking current flow:

1. `/sasu-review` handler
   - record explicit intent
   - record git/check context snapshot IDs
   - record review request dispatch mode (idle/follow-up)

2. `/sasu-suggest` and suggestion response handling
   - record suggested files + user selection/open actions

3. `/sasu-goal`
   - record manual override/lock events

4. `pi.on("agent_end")`
   - record review completion outcome
   - record parsed guidance artifacts

5. Existing collectors (`collectGitContext`, `runOptionalChecks`)
   - emit structured events from outputs

---

## 8) Intent inference (v0)

Output shape:

```ts
{
  hypotheses: Array<{ label: string; confidence: number; evidence: string[] }>;
  selected: {
    label: string;
    confidence: number;
    source: string;
  }
  needsClarification: boolean;
}
```

Scoring signals (deterministic first):

- explicit user intent text (strong)
- manual `sasu-goal` override (highest priority)
- dominant changed paths/modules
- failing checks linked to touched areas
- last accepted suggestions

Policy:

- If manual goal is locked/recent, do not auto-overwrite.
- Ask a single clarification only when confidence below threshold.

---

## 9) Mission Brief contract (token budget)

Before `/sasu-review`, build a compact brief:

```md
## SASU Mission Brief

Intent: ... (confidence)
Active focus: ...
Recent evidence:

- changed areas
- failing checks/diagnostics
  Top risks:

1. ...
   Next validation step:

- ...
```

Budget rules:

- Hard cap: ~1800 tokens (configurable)
- Include top-K evidence only (ranked by relevance)
- Never include raw full history or full event dump
- Diff snippets are targeted, not full diff by default

---

## 10) Risk model (v0)

Risk must be structured to surface:

```ts
{
  type: "api_break" | "logic_regression" | "coverage_gap" | "migration_mismatch" | "perf" | "security";
  impact: number;       // 0..1
  confidence: number;   // 0..1
  evidence: string[];   // file/symbol/check refs
  nextStep: string;
}
```

Priority:
`priority = impact * confidence * actionability`

UI routing policy:

- low: statusline only
- medium: panel only
- high: panel + line anchor
- critical: explicit notification

---

## 11) Prompt/cache safety rules

- Do not stream dynamic memory blobs into system prompt every turn.
- Prefer command-time brief assembly (`/sasu-review`, `/sasu-suggest`).
- Keep tool schema static.
- Keep memory retrieval append-only and explicit.

---

## 12) Neovim ambient integration model

v0 (practical):

- SASU memory updates mostly from existing Pi/SASU hooks.
- Optional Neovim event feeder can append structured events later.

v1:

- Add Neovim panel + statusline + sparse anchors backed by `working_state`.
- Only show proactive hints on high priority and novelty.

---

## 13) Implementation plan

### Phase 0 (foundation)

- Add `src/memory/` module with:
  - `types.ts`
  - `store.ts` (SQLite access)
  - `ingest.ts`
  - `reducers.ts`
  - `brief.ts`
- Add migration/init creating `.sasu/context.db`
- Add basic commands:
  - `/sasu-memory-status`
  - `/sasu-memory-tail`

### Phase 1 (review integration)

- Replace direct goal fallback path in `/sasu-review` with `resolveIntentContext()` from memory.
- Use `buildMissionBrief()` as review preamble.
- Preserve existing busy/queue/notification behavior.

### Phase 2 (ambient UX)

- Panel/statusline/anchors using risk routing policy.
- Feedback capture from user actions for adaptive ranking.

---

## 14) Practical viability

This is viable if we keep scope narrow:

- local SQLite only,
- deterministic inference first,
- strict token budget,
- additive integration (no rewrite of current SASU flow).

Expected value quickly:

- less manual goal management,
- better intent continuity,
- more evidence-backed guidance.

---

## 15) Acceptance criteria for v0

- `/sasu-review` works without manual goal entry in most loops.
- Mission brief includes explicit evidence references.
- Prompt size remains bounded (configured cap).
- Existing review queue/busy semantics unchanged.
- Memory observability commands expose current state/debug info.
