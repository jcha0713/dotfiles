#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
handlers_dir="$root/scripts/update-pkg.d"

map_handler_to_pkg() {
  basename "$1" .sh
}

printf '%-20s %-16s %-16s %s\n' "PACKAGE" "CURRENT" "LATEST" "STATUS"

found=0
for handler in "$handlers_dir"/*.sh; do
  [[ -e "$handler" ]] || continue
  found=1

  pkg="$(map_handler_to_pkg "$handler")"
  if ! line="$($handler --status)"; then
    printf '%-20s %-16s %-16s %s\n' "$pkg" "error" "error" "error"
    continue
  fi

  IFS=$'\t' read -r name current latest status <<< "$line"
  printf '%-20s %-16s %-16s %s\n' "$name" "$current" "$latest" "$status"
done

if [[ "$found" -eq 0 ]]; then
  echo "No updatable packages configured." >&2
  exit 1
fi
