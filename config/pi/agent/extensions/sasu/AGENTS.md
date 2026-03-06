# sasu

## Goal

    Creating human-first agentic pair programming environment. Instead of infinitely feeding instructions via chat based UI, let human write the code first, then have an agent verifies the work.

The agent should

- know what I'm currently building
- understand what my next goal is
- scan `git diff` output so it can analyze the code changes, suggest what to edit, how to debug, where to look, etc.

## Implementation Protocol (Memory v0)

When working on SASU Memory v0, follow these project rules:

- Source of truth docs:
  - `docs/memory-spec-v0.md`
  - `docs/memory-spec-v0-checklist.md`
  - `docs/TESTING.md`
- Keep v0 memory architecture local-first:
  - use `.sasu/context.db` (SQLite)
  - do not require external memory services for v0
- Preserve existing review orchestration behavior:
  - keep `/sasu-review` busy/queue semantics intact
  - keep existing lifecycle flags/notifications intact

Validation requirements before reporting completion:

- `bash scripts/verify-memory-v0.sh`
- `bash scripts/verify-memory-v0.sh --strict`
