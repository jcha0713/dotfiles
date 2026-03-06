#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STRICT=0

for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    --help|-h)
      cat <<'EOF'
Usage: bash scripts/verify-memory-v0.sh [--strict]

Modes:
  default   Tooling + deterministic fixture replay + baseline docs checks
  --strict  Also enforce memory-v0 implementation contract checks
EOF
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

log() {
  printf '[verify-memory-v0] %s\n' "$1"
}

fail() {
  printf '[verify-memory-v0] ERROR: %s\n' "$1" >&2
  exit 1
}

need_tool() {
  local name="$1"
  command -v "$name" >/dev/null 2>&1 || fail "Missing required tool: $name"
}

assert_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Missing file: $path"
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  if ! rg -n --fixed-strings "$pattern" "$file" >/dev/null 2>&1; then
    fail "Expected pattern not found in $(realpath --relative-to="$ROOT_DIR" "$file"): $pattern"
  fi
}

log "Checking required tools"
need_tool bun
need_tool sqlite3
need_tool jq
need_tool git
need_tool rg

log "Running deterministic fixture replay"
bun run "$ROOT_DIR/scripts/replay-memory-smoke.ts" \
  --fixture "$ROOT_DIR/tests/fixtures/memory/events-basic.json" \
  --snapshot "$ROOT_DIR/tests/fixtures/memory/expected-summary.json"

log "Checking baseline spec artifacts"
assert_file "$ROOT_DIR/docs/memory-spec-v0.md"
assert_file "$ROOT_DIR/docs/memory-spec-v0-checklist.md"

if [[ "$STRICT" -eq 1 ]]; then
  log "Strict mode: enforcing implementation contracts"

  assert_file "$ROOT_DIR/src/memory/types.ts"
  assert_file "$ROOT_DIR/src/memory/store.ts"
  assert_file "$ROOT_DIR/src/memory/ingest.ts"
  assert_file "$ROOT_DIR/src/memory/reducers.ts"
  assert_file "$ROOT_DIR/src/memory/brief.ts"

  for kind in \
    "user.command.review" \
    "user.command.suggest" \
    "user.command.goal_set" \
    "user.intent.explicit" \
    "code.git.snapshot" \
    "code.files.changed" \
    "check.run.result" \
    "agent.review.requested" \
    "agent.review.completed" \
    "agent.suggestion.generated" \
    "user.suggestion.action" \
    "focus.override.manual"; do
    assert_contains "$ROOT_DIR/src/memory/types.ts" "$kind"
  done

  assert_contains "$ROOT_DIR/src/memory/store.ts" "context.db"
  assert_contains "$ROOT_DIR/src/memory/store.ts" "CREATE TABLE"
  assert_contains "$ROOT_DIR/src/memory/store.ts" "events"
  assert_contains "$ROOT_DIR/src/memory/store.ts" "working_state"
  assert_contains "$ROOT_DIR/src/memory/store.ts" "episodes"
  assert_contains "$ROOT_DIR/src/memory/store.ts" "feedback"

  assert_contains "$ROOT_DIR/src/memory/brief.ts" "resolveIntentContext"
  assert_contains "$ROOT_DIR/src/memory/brief.ts" "buildMissionBrief"
  assert_contains "$ROOT_DIR/src/memory/brief.ts" "Evidence refs (top-K)"

  assert_contains "$ROOT_DIR/index.ts" "sasu-memory-status"
  assert_contains "$ROOT_DIR/index.ts" "sasu-memory-tail"
  assert_contains "$ROOT_DIR/index.ts" "sasu-memory-reset"

  assert_file "$ROOT_DIR/scripts/manual-smoke-memory-v0.sh"
  assert_file "$ROOT_DIR/tests/manual/memory-v0-smoke-template.md"
  assert_contains "$ROOT_DIR/docs/TESTING.md" "manual-smoke-memory-v0.sh"
fi

log "OK"
