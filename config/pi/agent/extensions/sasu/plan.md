# SASU — Structured Agentic Software Understanding

## Vision

SASU is a **simple, human-first review loop**:

- Human writes the code.
- Agent reviews, validates, and guides.
- Workflow stays lightweight and optional, not restrictive.

The goal is to avoid AI-overwriting developer ownership while still getting strong guidance.

---

## Real Problem SASU Solves

Modern agentic workflows can make people delegate too much implementation to AI. That creates:

- weaker coding practice,
- weaker understanding of the codebase,
- higher long-term maintenance burden.

SASU keeps the human in the driver seat by default: **you implement first, then request review when ready**.

---

## Product Principles

1. **Human-first**: user writes code; agent primarily reviews.
2. **Minimal ceremony**: user can start coding immediately.
3. **Best-effort context**: gather goal, intent, diff, and errors when available.
4. **No hard gates**: review loop should not block progress.
5. **Clarity over automation**: explain what changed, what is risky, what to do next.

---

## Scope (MVP)

### In scope

- Auto-detect project goal from docs.
- Ask user for goal only when no goal is found.
- User-triggered review command (`:BackToPi [optional message]`).
- Review packet built from:
  - user message (intent),
  - project goal,
  - git diff (if available),
  - error states (if available).
- Agent review output with clear guidance and next steps.
- Optional file suggestions for what to edit next.

### Out of scope (for now)

- Mandatory task state machines.
- Forced editor opening hooks.
- Hard pass/fail enforcement.
- Auto-applying code edits by default.

---

## End-to-End Workflow

## 1) Session bootstrap (automatic)

When SASU starts in a project:

1. Try to infer the project goal from docs (priority order):
   - `AGENTS.md`
   - `plan.md`
   - `README.md`
2. If no clear goal is found, ask once:
   - “What are you building in this session?”
3. Save this as session context.

Result: user has a known goal context, with almost zero setup friction.

---

## 2) User implementation phase (freeform)

- User edits any file at any time.
- SASU does not force file opening or impose strict phases.
- If desired, user can use optional helper command (`:SasuOpen`) when the agent suggests files.

Result: user stays in natural coding flow.

---

## 3) Review trigger

When user feels confident, run:

- `:BackToPi`
- or `:BackToPi <intent message>`

Intent examples:
- “I refactored auth middleware to reduce duplication.”
- “I think this fixes the race in queue retries.”

Result: user controls when review happens and what intention the agent should evaluate.

---

## 4) Context collection for review (best-effort)

On `:BackToPi`, SASU builds a review packet with best available data:

1. **Goal context**
   - from detected docs or prior user-provided goal.
2. **User intent**
   - message attached to `:BackToPi` (optional).
3. **Code changes**
   - git changed files + diff (staged and unstaged when possible).
4. **Error states** (optional)
   - configured checks (lint/test/typecheck),
   - editor/LSP diagnostics when available.

If any source is unavailable, SASU includes that fact and continues (no hard failure).

---

## 5) Agent review behavior

Given the packet, agent should return:

1. **Intent alignment**
   - “Based on your message, you were trying to…”
2. **Change summary**
   - what changed by file or component.
3. **Issues and risks**
   - prioritize by severity (critical / important / nice-to-have).
4. **Guidance**
   - concrete next edits, debugging steps, and where to inspect.
5. **Optional next file suggestions**
   - short list of files likely worth editing next.

Result: focused review that helps user continue coding independently.

---

## 6) Iterate

After review, user can:

- continue coding,
- ask follow-up questions,
- submit another `:BackToPi` when ready.

No forced “task complete” ritual is required in MVP.

---

## Commands (MVP)

- `:BackToPi`
  - Submit current work for review.
- `:BackToPi <message>`
  - Submit with explicit intention/context.
- `:SasuStatus`
  - Show detected goal + last review metadata.
- `:SasuOpen` (optional)
  - Open picker for agent-suggested files, if any exist.

---

## Minimal Architecture

```
sasu/
├── lua/sasu/
│   ├── init.lua        -- setup + command registration
│   ├── session.lua     -- tiny session persistence
│   ├── goal.lua        -- detect goal from docs / ask user fallback
│   ├── review.lua      -- build review packet and send to agent
│   ├── errors.lua      -- optional diagnostics/check collection
│   └── picker.lua      -- optional suggested-files picker
├── plugin/sasu.lua     -- user commands (:BackToPi, :SasuStatus, :SasuOpen)
└── README.md
```

Design rule: each module should be small and optional where possible.

---

## Session Data (minimal)

```json
{
  "version": 1,
  "project": "/path/to/project",
  "goal": "Add user authentication and session management",
  "goal_source": "AGENTS.md",
  "last_intent": "Refactor middleware and fix retry race",
  "last_review_at": "2026-03-02T13:00:00Z",
  "last_suggested_files": [
    { "path": "src/auth/middleware.ts", "reason": "duplicated checks" },
    { "path": "src/queue/retry.ts", "reason": "race condition path" }
  ]
}
```

No mandatory task/checkpoint schema in MVP.

---

## Fallback and Failure Handling

1. **No goal found in docs**
   - ask user once and continue.
2. **No git repo or no diff**
   - review from user intent + available files/errors.
3. **No diagnostics/checks available**
   - skip error section and continue.
4. **Very large diff**
   - summarize high-impact files first; drill down on request.
5. **No suggested files returned**
   - `:SasuOpen` informs user gracefully.

SASU should degrade gracefully, never dead-end.

---

## Success Criteria

1. User can start coding immediately without workflow setup burden.
2. SASU can infer goal from docs in most projects.
3. User can submit review with optional intent message.
4. Agent review reflects goal + intent + code changes + errors when available.
5. Feedback is actionable (what to edit, debug, inspect next).
6. Workflow feels lightweight enough to use repeatedly during normal development.

---

## Future Enhancements (after MVP)

- Better goal extraction from multiple docs.
- Better diff chunking/summarization for large changes.
- Per-language default check presets (TS, Python, Rust, etc.).
- Optional “apply fix” flow (explicit opt-in only).
- Rich Neovim diagnostics integration (still optional).

---

## Summary

SASU is not a rigid task engine.
It is a **simple review loop** that preserves developer ownership:

1. detect goal,
2. let user code freely,
3. review when user requests,
4. provide concrete guidance,
5. repeat.

This directly addresses the core problem: helping developers keep coding skill and code ownership while still benefiting from agent intelligence.