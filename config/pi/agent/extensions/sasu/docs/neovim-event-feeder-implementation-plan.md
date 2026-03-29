# Neovim event feeder — implementation plan (no-code)

## Objective

Validate that a minimal Neovim event feeder materially improves SASU review quality and focus continuity, without introducing event spam or orchestration risk.

## Constraints

- Keep Memory v0 local-first (`.sasu/context.db`) and reuse current ingestion path.
- Use existing event kinds first (no schema expansion initially).
- No proactive ambient AI behavior yet; feeder is passive data input only.
- Keep `/sasu-review` queue/busy semantics untouched.

## Success metrics

A run is successful when these are true in normal coding loops:

1. `memory-tail` shows feeder events reliably.
2. `/sasu-review` mission brief evidence aligns with recently edited files.
3. Intent context more frequently resolves via manual focus or strong evidence, not fallback.
4. Event volume is controlled (no high-frequency noisy bursts).

---

## Phase 1: feeder contract + transport shape

Define and freeze a tiny contract for Neovim→SASU emission:

- Required: `source`, `kind`, `payload`, `projectRoot`, `ts`
- Source fixed as `nvim`
- Relative file paths only
- No raw buffer/text payload

Transport recommendation:

- Feed events through SASU ingestion (same path as existing events), not direct SQLite writes.
- Preserve dedupe/fingerprint behavior by reusing ingest pipeline.

Exit criteria:

- Can submit a synthetic `nvim` event and observe it in `/sasu-memory-tail`.

Current implementation support:

- Use `/sasu-memory-ingest-nvim <json-envelope>` for contract validation + ingestion-path transport test.
- Example:

```text
/sasu-memory-ingest-nvim {"source":"nvim","kind":"code.files.changed","payload":{"origin":"nvim.buf_write","files":["src/memory/brief.ts"],"reason":"save"},"projectRoot":"<cwd>","ts":"2026-03-06T09:00:00.000Z"}
```

---

## Phase 2: Hook A — save signal (`BufWritePost`)

Emit on save:

- `kind`: `code.files.changed`
- `payload`: `{ origin: "nvim.buf_write", files: ["rel/path"], reason: "save" }`

Purpose:

- Keep `changed_areas` current even before Git-based collection runs.

Validation:

- Save a file in Neovim.
- `/sasu-memory-tail 10 --kind code.files.changed` shows the event.
- `/sasu-review` includes that file in mission brief evidence refs.

Exit criteria:

- Stable file-save events with no duplicate storm on repeated writes.

Current implementation support:

- `/sasu-memory-ingest-nvim-save <path-or-json>` builds a phase-2 save envelope and ingests via the normal memory pipeline.
- Accepts relative or absolute file path input; persisted payload is normalized to project-relative path.
- Repeated identical save events are deduped by existing fingerprint/window logic.
- Neovim auto-emitter plugin implemented at `neovim-sasu-feeder/`:
  - registers `BufWritePost`
  - sends `/sasu-memory-ingest-nvim-save {"file":"<abs-path>","ts":"..."}` to active `pi-nvim` terminal session

Examples:

```text
/sasu-memory-ingest-nvim-save src/memory/brief.ts
/sasu-memory-ingest-nvim-save {"file":"/abs/path/to/project/src/memory/brief.ts","ts":"2026-03-06T10:00:00.000Z"}
```

---

## Phase 3: Hook B — explicit focus lock (`:SasuFocus <text>`)

Emit on manual focus command:

- `kind`: `focus.override.manual`
- `payload`: `{ focus: "...", locked: true, sourceCommand: "nvim:SasuFocus" }`

Purpose:

- Enforce deterministic focus and prevent low-confidence fallback drift.

Validation:

- Run `:SasuFocus ...`
- `/sasu-review` shows `manual_override` intent context and `Needs clarification: no`.

Exit criteria:

- Manual focus consistently wins over weak inferred intent.

---

## Phase 4: Hook C — diagnostics signal (`DiagnosticChanged`, debounced)

Emit diagnostics summary events with debounce and change gating:

- `kind`: `check.run.result`
- `payload`: `{ origin: "nvim.diagnostics", name: "nvim.diagnostics", command: "nvim.diagnostics", status, files, errorCount, warningCount }`
- Status rule: `fail` when `errorCount > 0`, else `pass`.

Purpose:

- Keep `last_checks` and validation context fresh between explicit check runs.

Validation:

- Introduce an error → expect `fail` event.
- Fix error → expect `pass` event.
- Mission brief reflects failing checks when present.

Exit criteria:

- Diagnostics events are informative, low-frequency, and reflected in mission brief.

---

## Phase 5: integrated workflow evaluation

Run several normal loops:

1. set/adjust focus
2. edit + save
3. trigger/fix diagnostics
4. run `/sasu-review`
5. inspect `/sasu-memory-tail`

Evaluate against success metrics:

- Better relevance of review guidance
- Lower fallback intent usage
- Cleaner evidence refs
- Acceptable event noise

Go/no-go decision:

- **Go**: proceed to ambient UX experiments (panel/statusline/risk routing).
- **No-go**: keep feeder minimal and refine debounce/gating/payload quality first.

---

## Risk controls

- Debounce diagnostics updates.
- Suppress unchanged snapshots.
- Keep payloads concise.
- Add clear origin tags for traceability (`nvim.buf_write`, `nvim.diagnostics`, etc.).
- Avoid introducing auto-dispatch logic in this phase.

---

## Optional follow-ons after success

- Richer test events from quickfix/test runners (`check.run.result` with real command names)
- Novelty/cooldown policy before proactive hints
- Risk routing into panel/statusline once signal quality is proven
