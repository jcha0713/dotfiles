#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
handlers_dir="$root/scripts/update-pkg.d"

list_packages() {
  find "$handlers_dir" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' \
    | sed 's/\.sh$//' \
    | sort
}

usage() {
  cat >&2 <<EOF
Usage:
  $(basename "$0") <pkg> [version]

Examples:
  $(basename "$0") gitbutler-cli
  $(basename "$0") gitbutler-cli --latest
  $(basename "$0") gitbutler-cli 0.19.5-2897

If [version] is omitted, --latest is used.

Available packages:
$(list_packages | sed 's/^/  - /')
EOF
  exit 1
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
fi

pkg="$1"
version="${2:---latest}"

case "$pkg" in
  gitbutler)
    pkg="gitbutler-cli"
    ;;
esac

handler="$handlers_dir/${pkg}.sh"

if [[ ! -f "$handler" ]]; then
  echo "Unsupported package: $pkg" >&2
  echo >&2
  usage
fi

exec "$handler" "$version"
