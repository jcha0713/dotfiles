# SASU Memory v0 — Concrete Task Breakdown Checklist

Derived from: `memory-spec-v0.md`  
Scope: `config/pi/agent/extensions/sasu`

---

## Milestone 0 — Preflight / Safety

- [ ] Create a context tag before memory work starts (recommended): `memory-v0-start`
- [ ] Confirm current extension builds/tests pass before changes
- [ ] Verify current `/sasu-review` busy/queue semantics baseline:
  - [ ] idle dispatch path works
  - [ ] follow-up queue path works
  - [ ] notifications and lifecycle flags still correct

**Done when:** baseline behavior is documented and reproducible.

---

## Milestone 1 — Memory module scaffold (`src/memory/`)

### 1.1 Types and contracts
- [x] Create `src/memory/types.ts`
- [x] Define event taxonomy union:
  - [x] `user.command.review`
  - [x] `user.command.suggest`
  - [x] `user.command.goal_set`
  - [x] `user.intent.explicit`
  - [x] `code.git.snapshot`
  - [x] `code.files.changed`
  - [x] `check.run.result`
  - [x] `agent.review.requested`
  - [x] `agent.review.completed`
  - [x] `agent.suggestion.generated`
  - [x] `user.suggestion.action`
  - [x] `focus.override.manual`
- [x] Define `MemoryEvent` shape (`id`, `ts`, `projectRoot`, `sessionId`, `source`, `kind`, `payload`, `fingerprint?`)
- [x] Define `WorkingState` keys/contracts:
  - [x] `intent_hypotheses`
  - [x] `active_focus`
  - [x] `changed_areas`
  - [x] `open_risks`
  - [x] `last_checks`
  - [x] `last_review_summary`
- [x] Define mission brief and risk interfaces

### 1.2 SQLite store
- [x] Create `src/memory/store.ts`
- [x] Add DB path resolver: `.sasu/context.db`
- [x] Add init/migration function creating tables:
  - [x] `events`
  - [x] `working_state`
  - [x] `episodes`
  - [x] `feedback`
- [x] Add indexes:
  - [x] `(project_root, ts DESC)`
  - [x] `(kind, ts DESC)`
  - [x] `(session_id, ts DESC)`
- [x] Add store methods:
  - [x] `appendEvent(event)`
  - [x] `appendEvents(events[])`
  - [x] `queryEvents(filters)`
  - [x] `upsertWorkingState(key, value)`
  - [x] `getWorkingState(key)`
  - [x] `getWorkingStateSnapshot()`
  - [x] `resetAll()` (for debug command)

### 1.3 Ingest + reducers
- [x] Create `src/memory/ingest.ts`
- [x] Implement event validation/normalization
- [x] Implement fingerprint-based dedup policy (best-effort)
- [x] Create `src/memory/reducers.ts`
- [x] Implement deterministic reducers for:
  - [x] changed areas
  - [x] last checks
  - [x] explicit/manual intent tracking
  - [x] last review summary
- [x] Add `reduceFromEvent(event)` and `rebuildSnapshot(from events)`

### 1.4 Mission brief builder
- [x] Create `src/memory/brief.ts`
- [x] Implement `resolveIntentContext()`
- [x] Implement `buildMissionBrief()`
- [x] Enforce token budget cap (default ~1800 tokens)
- [x] Add top-K evidence ranking + truncation
- [x] Ensure no full-history/full-diff dump in brief

**Done when:** `src/memory/` has compile-ready contracts + storage + reducers + brief builder.

---

## Milestone 2 — Wire ingest into existing SASU flow

### 2.1 Command-level ingestion
- [x] Update `index.ts` `/sasu-review` handler:
  - [x] emit `user.command.review`
  - [x] emit `user.intent.explicit` (if provided)
  - [x] emit `agent.review.requested` with dispatch mode (`idle`/`followUp`)
- [x] Update `/sasu-suggest` path:
  - [x] emit `user.command.suggest`
  - [x] emit `agent.suggestion.generated`
- [x] Update `/sasu-goal` path:
  - [x] emit `user.command.goal_set`
  - [x] emit `focus.override.manual`

### 2.2 Collector ingestion
- [x] Ingest structured output from git context collection:
  - [x] `code.git.snapshot`
  - [x] `code.files.changed`
- [x] Ingest optional checks output:
  - [x] `check.run.result`

### 2.3 Lifecycle ingestion
- [x] In `pi.on("agent_end")` review completion path:
  - [x] emit `agent.review.completed`
- [x] In suggestion action handling:
  - [x] emit `user.suggestion.action`
  - [x] write `feedback` row (`accepted|dismissed|ignored|edited`)

**Done when:** every major SASU review/suggest/goal loop emits memory events with evidence references.

---

## Milestone 3 — Review integration (replace direct fallback)

- [x] Integrate `resolveIntentContext()` into `/sasu-review` preflight
- [x] Build review preamble from `buildMissionBrief()`
- [x] Keep current review orchestration untouched:
  - [x] `isBusyWaiting()` behavior unchanged
  - [x] follow-up queueing unchanged
  - [x] `awaitingReviewResponse`/`skipNextReviewAgentEnd` semantics unchanged
  - [x] existing notify UX preserved
- [x] Ensure `/sasu-review` works when memory DB is missing/uninitialized (graceful fallback)

**Done when:** `/sasu-review` uses memory-derived mission brief while preserving lifecycle behavior.

---

## Milestone 4 — Memory debug/ops commands

- [x] Add `/sasu-memory-status`
  - [x] DB health/init status
  - [x] event counts by kind
  - [x] current working_state keys summary
- [x] Add `/sasu-memory-tail`
  - [x] show latest N events (default + arg)
  - [x] optional filter by `kind`
- [x] Add `/sasu-memory-reset`
  - [x] confirmation guard
  - [x] clears DB tables safely

**Done when:** memory can be inspected/reset without touching files manually.

---

## Milestone 5 — Tests and validation

### 5.1 Unit tests
- [x] `types` validation tests (scaffold)
- [x] `store` migration/init tests (scaffold)
- [x] `ingest` dedup tests
- [x] `reducers` deterministic state update tests (scaffold)
- [x] `brief` token-cap/truncation tests (scaffold)

### 5.2 Integration tests
- [x] `/sasu-review` idle path uses mission brief
- [x] `/sasu-review` follow-up path uses mission brief
- [x] busy/queue semantics unchanged
- [x] `/sasu-suggest` + suggestion actions write feedback
- [x] `/sasu-goal` override blocks low-confidence auto intent replacement

### 5.3 Manual smoke checklist
- [x] Fresh repo: DB auto-creates
- [x] Existing repo: no crash/regression
- [x] No visible chat prompt spam regression
- [x] Memory commands produce useful output

**Done when:** both automated and manual checks pass.

---

## Milestone 6 — v0 acceptance gate

- [x] `/sasu-review` works in most loops without manual goal setting
- [x] Mission brief includes explicit evidence refs (files/checks)
- [x] Prompt remains bounded by configured token budget
- [x] Existing review queue/busy semantics preserved
- [x] Memory status/tail/reset commands available and usable

**Ship v0 when all items are checked.**

---

## Recommended execution order (day-by-day)

### Day 1
- [x] Milestone 1.1 + 1.2 (types + store)
- [x] Milestone 4 (`/sasu-memory-status` minimal)

### Day 2
- [x] Milestone 1.3 + 1.4 (reducers + brief)
- [x] Milestone 2.1 (review/goal/suggest event wiring)

### Day 3
- [x] Milestone 2.2 + 2.3 (collector + lifecycle wiring)
- [x] Milestone 3 (review integration)

### Day 4
- [x] Milestone 5 (tests/smokes)
- [x] Milestone 6 acceptance + cleanup docs

---

## Stretch (post-v0, optional)

- [ ] novelty filter + cooldown gating for proactive hints
- [ ] panel/statusline risk routing
- [ ] Neovim event feeder for richer focus inference
- [ ] optional external semantic retrieval adapter (momo-like)
