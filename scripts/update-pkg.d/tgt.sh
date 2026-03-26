#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
flake_lock="$root/flake.lock"
package_file="$root/pkgs/tgt/default.nix"
input_name="tgt"
repo_ref="github:FedericoBruzzone/tgt"
package_name="tgt"
fake_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

usage() {
  cat <<'EOF' >&2
Usage:
  tgt.sh <rev-or-ref>
  tgt.sh --latest
  tgt.sh --current-version
  tgt.sh --latest-version
  tgt.sh --status

Examples:
  tgt.sh --latest
  tgt.sh 0b5b42c0a17c86c13836d8535d1a207f4bb24d74
  tgt.sh main
EOF
  exit 1
}

current_version() {
  jq -r --arg input "$input_name" '.nodes[$input].locked.rev // empty' "$flake_lock"
}

latest_version() {
  nix flake metadata --json "$repo_ref" | jq -r '.revision // empty'
}

short_rev() {
  printf '%s' "$1" | cut -c1-12
}

set_cargo_hash() {
  local hash="$1"
  perl -0pi -e 's|cargoHash\s*=\s*"[^"]+";|cargoHash = "'"$hash"'";|s' "$package_file"
}

package_expr_file() {
  local expr_file
  expr_file="$(mktemp --suffix .nix)"
  cat > "$expr_file" <<EOF
let
  flake = builtins.getFlake (toString $root);
  system = builtins.currentSystem;
  pkgs = import flake.inputs.nixpkgs { inherit system; };
in
pkgs.callPackage $root/pkgs/tgt/default.nix { inherit (flake) inputs; }
EOF
  printf '%s\n' "$expr_file"
}

extract_got_hash() {
  sed -nE 's/.*got:\s+(sha256-[A-Za-z0-9+/=]+).*/\1/p' "$1" | tail -n 1
}

refresh_cargo_hash() {
  local expr_file stderr_file actual_hash
  expr_file="$(package_expr_file)"
  stderr_file="$(mktemp)"

  set_cargo_hash "$fake_hash"

  if nix build --impure --no-link --file "$expr_file" >/dev/null 2>"$stderr_file"; then
    echo "Build unexpectedly succeeded with fake cargoHash" >&2
    rm -f "$expr_file" "$stderr_file"
    exit 1
  fi

  actual_hash="$(extract_got_hash "$stderr_file")"
  rm -f "$expr_file" "$stderr_file"

  if [[ -z "$actual_hash" ]]; then
    echo "Failed to determine cargoHash for $package_name" >&2
    exit 1
  fi

  echo "Resolved cargoHash: $actual_hash"
  set_cargo_hash "$actual_hash"
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

  printf '%s\t%s\t%s\t%s\n' "$package_name" "$(short_rev "$current")" "$(short_rev "$latest")" "$state"
}

update_latest() {
  echo "Updating $package_name to latest..."
  nix flake update "$input_name" --flake "$root"
}

update_to_ref() {
  local ref="$1"
  local tmp_lock
  tmp_lock="$(mktemp)"
  cp "$flake_lock" "$tmp_lock"

  echo "Updating $package_name to ref: $ref"
  nix flake update "$input_name" \
    --flake "$root" \
    --override-input "$input_name" "$repo_ref/$ref" \
    --output-lock-file "$tmp_lock"

  mv "$tmp_lock" "$flake_lock"
}

validate_package_build() {
  local expr_file
  expr_file="$(package_expr_file)"
  echo "Validating $package_name build..."
  nix build --impure --no-link --file "$expr_file" >/dev/null
  rm -f "$expr_file"
}

validate_configs() {
  echo "Validating configuration evaluation..."
  nix eval "$root#nixosConfigurations.think.config.home-manager.users.joohoon.home.packages" --apply builtins.length >/dev/null
  nix eval "$root#darwinConfigurations.mini.config.home-manager.users.jcha0713.home.packages" --apply builtins.length >/dev/null
}

finish() {
  local current
  current="$(current_version)"

  echo
  echo "Updated $package_name to $(short_rev "$current")"
  echo
  echo "Next steps:"
  echo "  git diff -- flake.lock pkgs/tgt/default.nix"
  echo "  ya rebuild"
}

if [[ $# -ne 1 ]]; then
  usage
fi

case "$1" in
  --current-version)
    current_version
    ;;
  --latest-version)
    latest_version
    ;;
  --status)
    status_line
    ;;
  --latest)
    update_latest
    refresh_cargo_hash
    validate_package_build
    validate_configs
    finish
    ;;
  *)
    update_to_ref "$1"
    refresh_cargo_hash
    validate_package_build
    validate_configs
    finish
    ;;
esac
