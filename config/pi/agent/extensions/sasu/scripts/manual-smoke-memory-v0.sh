#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE=""
KEEP=1

usage() {
  cat <<'EOF'
Usage: bash scripts/manual-smoke-memory-v0.sh [--workspace DIR] [--cleanup]

Prepares two runnable repos for milestone 5.3 manual smoke checks:
  1) fresh-repo    (no pre-existing .sasu DB)
  2) existing-repo (pre-seeded .sasu/context.db + session)

Options:
  --workspace DIR  Create/reuse workspace directory
  --cleanup        Remove workspace after printing summary (default: keep)
  --help, -h       Show help
EOF
}

log() {
  printf '[manual-smoke-memory-v0] %s\n' "$1"
}

need_tool() {
  local name="$1"
  command -v "$name" >/dev/null 2>&1 || {
    printf '[manual-smoke-memory-v0] ERROR: missing required tool: %s\n' "$name" >&2
    exit 1
  }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      if [[ $# -lt 2 ]]; then
        printf '[manual-smoke-memory-v0] ERROR: --workspace requires a value\n' >&2
        exit 2
      fi
      WORKSPACE="$2"
      shift 2
      ;;
    --cleanup)
      KEEP=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf '[manual-smoke-memory-v0] ERROR: unknown arg: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

need_tool git
need_tool sqlite3

if [[ -z "$WORKSPACE" ]]; then
  WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/sasu-memory-v0-smoke-XXXXXX")"
else
  mkdir -p "$WORKSPACE"
fi

FRESH_REPO="$WORKSPACE/fresh-repo"
EXISTING_REPO="$WORKSPACE/existing-repo"
TEMPLATE_PATH="$ROOT_DIR/tests/manual/memory-v0-smoke-template.md"
RUNBOOK_PATH="$WORKSPACE/memory-v0-smoke-runbook.md"

init_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.name "SASU Smoke"
  git -C "$repo" config user.email "sasu-smoke@example.com"
}

seed_common_files() {
  local repo="$1"
  local goal="$2"

  mkdir -p "$repo/src"
  cat > "$repo/README.md" <<EOF
# Smoke Playground

## Goal
$goal
EOF

  cat > "$repo/src/main.ts" <<'EOF'
export function smokeFlag(): string {
  return "ready";
}
EOF

  git -C "$repo" add README.md src/main.ts
  git -C "$repo" commit -q -m "chore: bootstrap smoke repo"

  cat >> "$repo/src/main.ts" <<'EOF'

export const changedInSmoke = true;
EOF
}

seed_existing_memory() {
  local repo="$1"
  local db_path="$repo/.sasu/context.db"
  mkdir -p "$repo/.sasu"

  sqlite3 "$db_path" >/dev/null <<SQL
PRAGMA journal_mode = WAL;
CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  ts TEXT NOT NULL,
  project_root TEXT NOT NULL,
  session_id TEXT,
  source TEXT NOT NULL,
  kind TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  fingerprint TEXT
);
CREATE TABLE IF NOT EXISTS working_state (
  key TEXT PRIMARY KEY,
  value_json TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS episodes (
  id TEXT PRIMARY KEY,
  start_ts TEXT NOT NULL,
  end_ts TEXT,
  summary TEXT,
  intent_json TEXT,
  evidence_json TEXT,
  outcome_json TEXT
);
CREATE TABLE IF NOT EXISTS feedback (
  id TEXT PRIMARY KEY,
  ts TEXT NOT NULL,
  suggestion_id TEXT,
  action TEXT NOT NULL,
  context_json TEXT
);
INSERT OR REPLACE INTO events (
  id, ts, project_root, session_id, source, kind, payload_json, fingerprint
) VALUES (
  'seed-event-1',
  '2026-03-05T00:00:00.000Z',
  '$repo',
  'seed-session',
  'sasu',
  'focus.override.manual',
  '{"focus":"existing repo seeded focus"}',
  'seed:f1'
);
INSERT OR REPLACE INTO working_state (key, value_json, updated_at) VALUES (
  'active_focus',
  '{"label":"existing repo seeded focus","source":"focus.override.manual","locked":true,"updatedAt":"2026-03-05T00:00:00.000Z"}',
  '2026-03-05T00:00:00.000Z'
);
SQL

  cat > "$repo/.sasu/session.json" <<'EOF'
{
  "version": 1,
  "projectGoal": "Validate memory behavior in existing repositories",
  "projectGoalSource": "manual-smoke-seed"
}
EOF
}

log "Preparing manual smoke repos under: $WORKSPACE"

rm -rf "$FRESH_REPO" "$EXISTING_REPO"
init_repo "$FRESH_REPO"
seed_common_files "$FRESH_REPO" "Validate fresh-repo memory DB bootstrap behavior"

init_repo "$EXISTING_REPO"
seed_common_files "$EXISTING_REPO" "Ensure existing repository flow has no regressions"
seed_existing_memory "$EXISTING_REPO"

if [[ -f "$TEMPLATE_PATH" ]]; then
  cp "$TEMPLATE_PATH" "$RUNBOOK_PATH"
fi

cat <<EOF

Prepared repositories:
- fresh repo:    $FRESH_REPO
- existing repo: $EXISTING_REPO

Milestone 5.3 manual smoke checklist support:
1) Open each repo in Pi (one at a time).
2) Follow the template:
   $RUNBOOK_PATH
3) Run these commands in each repo:
   - /sasu-memory-status
   - /sasu-memory-tail 20
   - /sasu-review smoke check intent
   - while review is in-flight, run /sasu-review again (queue behavior)
4) Confirm:
   - fresh repo auto-created .sasu/context.db
   - existing repo does not crash/regress
   - no visible prompt spam regression
   - memory commands produce useful output

DB quick checks:
- sqlite3 "$FRESH_REPO/.sasu/context.db" "SELECT COUNT(1) FROM events;"
- sqlite3 "$EXISTING_REPO/.sasu/context.db" "SELECT COUNT(1) FROM events;"

EOF

if [[ "$KEEP" -eq 0 ]]; then
  log "--cleanup set: removing workspace"
  rm -rf "$WORKSPACE"
else
  log "Workspace kept. Remove manually when done: rm -rf '$WORKSPACE'"
fi
