#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
package_file="$root/pkgs/gitbutler-cli/default.nix"
package_name="gitbutler-cli"

usage() {
  cat <<'EOF' >&2
Usage:
  gitbutler-cli.sh <version>
  gitbutler-cli.sh --latest
  gitbutler-cli.sh --current-version
  gitbutler-cli.sh --latest-version
  gitbutler-cli.sh --status

Examples:
  gitbutler-cli.sh 0.19.3-2869
  gitbutler-cli.sh --latest
EOF
  exit 1
}

resolve_latest_url() {
  curl -fsSL https://app.gitbutler.com/releases/ \
    | jq -r '.platforms["linux-x86_64"].url'
}

extract_version() {
  sed -nE 's|.*?/release/([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)/linux/x86_64/but$|\1|p'
}

current_version() {
  sed -nE 's/^\s*version = "([^"]+)";$/\1/p' "$package_file"
}

latest_version() {
  local url
  url="$(resolve_latest_url)"

  if [[ -z "$url" || "$url" == "null" ]]; then
    echo "Failed to resolve latest GitButler CLI URL" >&2
    exit 1
  fi

  printf '%s\n' "$url" | extract_version
}

status_line() {
  local current latest state
  current="$(current_version)"
  latest="$(latest_version)"

  if [[ -z "$current" || -z "$latest" ]]; then
    echo "Failed to determine package status for $package_name" >&2
    exit 1
  fi

  if [[ "$current" == "$latest" ]]; then
    state="up-to-date"
  else
    state="update-available"
  fi

  printf '%s\t%s\t%s\t%s\n' "$package_name" "$current" "$latest" "$state"
}

if [[ $# -ne 1 ]]; then
  usage
fi

case "$1" in
  --current-version)
    current_version
    exit 0
    ;;
  --latest-version)
    latest_version
    exit 0
    ;;
  --status)
    status_line
    exit 0
    ;;
  --latest)
    version="$(latest_version)"
    if [[ -z "$version" ]]; then
      echo "Failed to extract latest GitButler CLI version" >&2
      exit 1
    fi
    url="https://releases.gitbutler.com/releases/release/${version}/linux/x86_64/but"
    ;;
  *)
    version="$1"
    url="https://releases.gitbutler.com/releases/release/${version}/linux/x86_64/but"
    ;;
esac

echo "Prefetching GitButler CLI ${version}..."
hash="$(nix store prefetch-file --json "$url" | jq -r '.hash')"

if [[ -z "$hash" || "$hash" == "null" ]]; then
  echo "Failed to compute hash for $url" >&2
  exit 1
fi

echo "Updating $package_file"
perl -0pi -e 's/version = ".*?";/version = "'"$version"'";/; s/hash = ".*?";/hash = "'"$hash"'";/;' "$package_file"

cd "$root"
nixfmt "$package_file"

echo "Validating build..."
nix build --impure --no-link --expr 'let pkgs = import <nixpkgs> { config.allowUnfree = true; }; in pkgs.callPackage ./pkgs/gitbutler-cli {}'

echo
echo "Updated gitbutler-cli to ${version}"
echo "  url:  ${url}"
echo "  hash: ${hash}"
echo
echo "Next steps:"
echo "  git diff -- pkgs/gitbutler-cli/default.nix"
echo "  ya rebuild"
