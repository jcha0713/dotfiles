#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
handlers_dir="$root/scripts/update-pkg.d"

print_header() {
  printf '%-20s %-16s %-16s %s\n' "PACKAGE" "CURRENT" "LATEST" "STATUS"
}

resolve_pkg() {
  case "$1" in
    gitbutler)
      echo "gitbutler-cli"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

handler_for_pkg() {
  local pkg
  pkg="$(resolve_pkg "$1")"
  echo "$handlers_dir/${pkg}.sh"
}

print_status_row() {
  local input_pkg handler line name current latest status

  input_pkg="$1"
  handler="$(handler_for_pkg "$input_pkg")"

  if [[ ! -f "$handler" ]]; then
    echo "Unsupported package: $input_pkg" >&2
    exit 1
  fi

  line="$($handler --status)"
  IFS=$'\t' read -r name current latest status <<< "$line"
  printf '%-20s %-16s %-16s %s\n' "$name" "$current" "$latest" "$status"
}

usage() {
  cat >&2 <<'EOF'
Usage:
  package.sh update <pkg> [version]
  package.sh check <pkg>
  package.sh check-all

Examples:
  package.sh update gitbutler-cli
  package.sh update gitbutler-cli 0.19.5-2897
  package.sh update tgt
  package.sh check gitbutler-cli
  package.sh check tgt
  package.sh check-all
EOF
  exit 1
}

action="${1:-}"
pkg="${2:-}"
version="${3:-}"

case "$action" in
  update)
    if [[ -z "$pkg" ]]; then
      usage
    fi

    if [[ -n "$version" ]]; then
      exec "$root/scripts/update-pkg.sh" "$pkg" "$version"
    else
      exec "$root/scripts/update-pkg.sh" "$pkg"
    fi
    ;;
  check)
    if [[ -z "$pkg" ]]; then
      usage
    fi

    print_header
    print_status_row "$pkg"
    ;;
  check-all)
    exec "$root/scripts/updatable.sh"
    ;;
  *)
    usage
    ;;
esac
