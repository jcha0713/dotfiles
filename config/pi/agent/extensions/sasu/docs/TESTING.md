# SASU Memory v0 Testing Loop

This file defines the implementation feedback loop for `memory-spec-v0.md`.

## Prerequisites

Required tools in shell:

- `bun`
- `sqlite3`
- `jq`
- `git`
- `rg`

Quick check:

```bash
which bun sqlite3 jq git rg
```

## Commands

### 1) Baseline verify (always safe)

```bash
bash scripts/verify-memory-v0.sh
```

What it does:

- checks required tooling
- runs deterministic fixture replay (`scripts/replay-memory-smoke.ts`)
- confirms spec/checklist artifacts exist

### 2) Strict verify (after implementation starts)

```bash
bash scripts/verify-memory-v0.sh --strict
```

Adds contract checks for:

- `src/memory/{types,store,ingest,reducers,brief}.ts`
- event taxonomy coverage
- expected storage/brief function markers
- memory commands wired in `index.ts`

### 3) Update fixture snapshot (intentional contract changes)

```bash
bun run scripts/replay-memory-smoke.ts --update-snapshot
```

Only run this when fixture semantics are intentionally changed.

## Milestone 5.3 manual smoke support package

Use this flow to execute and record the manual smoke checklist quickly.

### 1) Prepare fresh/existing smoke repos

```bash
bash scripts/manual-smoke-memory-v0.sh
```

This script prepares:

- a **fresh repo** (no pre-existing `.sasu/context.db`)
- an **existing repo** (pre-seeded `.sasu/context.db` + session)
- a copied runbook template in the workspace (`memory-v0-smoke-runbook.md`)

### 2) Run Pi commands in each repo

1. `/sasu-memory-status`
2. `/sasu-memory-tail 20`
3. `/sasu-review smoke check intent`
4. while review is in-flight, run `/sasu-review` again (busy/follow-up path)

### 3) Record evidence

Use:

- `tests/manual/memory-v0-smoke-template.md`

Minimum expected signals:

- Fresh repo auto-creates `.sasu/context.db`
- Existing repo commands run without crash/regression
- No visible prompt spam regression (no duplicate request spam)
- Memory commands return useful, structured output

Common failure signatures to watch:

- repeated `sasu-review-request` blocks from one command invocation
- missing/empty memory status blocks after commands
- DB init errors (`sqlite3` missing table or path errors)
- broken follow-up queue behavior when review is already in-flight

## Neovim feeder phase-1 quick check

Use this to validate contract + transport before editor hook wiring:

```text
/sasu-memory-ingest-nvim {"source":"nvim","kind":"code.files.changed","payload":{"origin":"nvim.buf_write","files":["src/memory/brief.ts"],"reason":"save"},"projectRoot":"<cwd>","ts":"2026-03-06T09:00:00.000Z"}
/sasu-memory-tail 20 --kind code.files.changed
```

Expected:

- ingest command succeeds (no validation error)
- tail includes `code.files.changed | nvim`
- `working_state.changed_areas` includes emitted files

## Neovim feeder phase-2 quick check (save hook shape)

Use this to validate BufWritePost-style save events (without hand-crafting full envelope JSON):

```text
/sasu-memory-ingest-nvim-save src/memory/brief.ts
/sasu-memory-tail 20 --kind code.files.changed
/sasu-review
```

Expected:

- save ingest command succeeds
- tail shows latest `code.files.changed | nvim` with `origin=nvim.buf_write`
- repeated save of same file does not create a duplicate storm (dedupe window)
- mission brief evidence refs include the saved file path

## Neovim feeder phase-2 auto-emitter quick check

1. Load plugin from `neovim-sasu-feeder/` and run `:SasuFeederStatus` (terminal should report ready).
2. Open Pi terminal (`require("pi-nvim").open()`), edit + save a file in project.
3. In Pi, run:

```text
/sasu-memory-tail 20 --kind code.files.changed
```

Expected:

- latest event shows `code.files.changed | nvim`
- payload includes saved file path (normalized to project-relative)
- no noisy burst from a single save action

## Milestone 6 acceptance checks

Automated coverage now includes:

- `tests/memory/brief.test.ts` (top-K evidence refs + token-cap bounded brief)
- `tests/integration/milestone-5.2.integration.test.ts`:
  - `/sasu-review` without manual goal setting
  - explicit evidence refs in mission brief
  - busy/follow-up queue semantics
  - `/sasu-memory-status`, `/sasu-memory-tail`, `/sasu-memory-reset` usability

Run:

```bash
bun test
bash scripts/verify-memory-v0.sh --strict
```

## Iteration protocol

For each coding iteration, share:

- **Checklist target**: e.g. `Milestone 1.2 + 1.3`
- **Diff scope**: changed files
- **Verifier output**: `bash scripts/verify-memory-v0.sh --strict`
- **Runtime evidence**: command outputs listed above

Then the assistant can provide focused fix patches quickly.
