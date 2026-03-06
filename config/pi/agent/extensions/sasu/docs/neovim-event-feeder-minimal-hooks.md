# Neovim event feeder (minimal hooks, no-code sketch)

## Goal

Add only a few **high-signal** Neovim hooks that are easy to test and immediately improve SASU memory quality for `/sasu-review`.

Use existing v0 event kinds first (no taxonomy expansion required).

---

## Recommended minimal hook set (3)

### 1) Save hook: `BufWritePost` → `code.files.changed`

**When it fires**
- On file save only (not on every cursor move or text change).

**Event**
- `source`: `nvim`
- `kind`: `code.files.changed`
- `payload`:
  - `origin: "nvim.buf_write"`
  - `files: ["relative/path/to/file.ts"]`
  - `reason: "save"`

**Why this matters**
- Keeps `working_state.changed_areas` fresh between review cycles.
- Makes mission brief evidence refs closer to what you actually touched in editor.

**Easy manual test**
1. Edit `src/memory/brief.ts` in Neovim.
2. Save.
3. Run `/sasu-memory-tail 10 --kind code.files.changed`.
4. Expect latest event with that file path.

---

### 2) Explicit focus command: `:SasuFocus <text>` → `focus.override.manual`

**When it fires**
- Only when user explicitly sets/locks focus from Neovim.

**Event**
- `source`: `nvim`
- `kind`: `focus.override.manual`
- `payload`:
  - `focus: "<user text>"`
  - `locked: true`
  - `sourceCommand: "nvim:SasuFocus"`

**Why this matters**
- Gives deterministic intent selection (`manual_override`) and stops low-confidence drift.
- Best leverage per event for review quality.

**Easy manual test**
1. Run `:SasuFocus tighten mission brief evidence ranking`.
2. Run `/sasu-review`.
3. In prompt, expect:
   - `Memory-selected intent: ... via manual_override`
   - `Needs clarification: no`

---

### 3) Diagnostics hook: `DiagnosticChanged` (debounced) → `check.run.result`

**When it fires**
- On diagnostics updates, with debounce (e.g. 750–1500ms).
- Emit only when state meaningfully changes (count/severity changed).

**Event**
- `source`: `nvim`
- `kind`: `check.run.result`
- `payload`:
  - `origin: "nvim.diagnostics"`
  - `name: "nvim.diagnostics"`
  - `command: "nvim.diagnostics"`
  - `status: "fail" | "pass"`
  - `files: ["relative/path/to/current/file.ts"]`
  - `errorCount: <number>`
  - `warningCount: <number>`

**Status rule (simple)**
- `fail` if `errorCount > 0`
- `pass` if `errorCount === 0`

**Why this matters**
- Updates `working_state.last_checks` without waiting for explicit test commands.
- Lets mission brief surface failing areas and better “next validation step”.

**Easy manual test**
1. Introduce a syntax/type error in a file.
2. Wait for diagnostics update.
3. Run `/sasu-memory-tail 10 --kind check.run.result`.
4. Fix error and save.
5. Confirm a later `pass` event appears.

---

## Event feeder transport (recommended shape)

Use a small Neovim-side emitter that sends structured events to SASU ingestion (not direct SQL writes).

Why:
- Keep dedupe/fingerprint behavior.
- Keep reducer behavior consistent.
- Avoid schema drift and brittle DB coupling.

---

## Guardrails (important)

- Do not emit high-frequency noise events (cursor moved, every keystroke).
- Debounce diagnostics.
- Keep payloads small and deterministic.
- Use project-relative file paths.
- Do not include full buffer text in payload.

---

## “Done” criteria for this minimal feeder

- You can trigger each hook manually and see events in `/sasu-memory-tail`.
- `/sasu-review` prompt shows improved focus/evidence alignment after a short loop.
- Event volume remains manageable (no spam).

---

## Next hooks to consider later (not in minimal set)

- `QuickFixCmdPost` / test-run hook → richer `check.run.result` for real test commands.
- `BufEnter` with cooldown for weak focus hints (only if needed).
- Optional novelty/cooldown layer before any proactive ambient UI.
