#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: $0 <term> [<term> ...]" >&2
  exit 1
fi

help_txt="$(nvim --clean --headless '+lua io.write(vim.api.nvim_get_runtime_file("doc/help.txt", false)[1] or "")' +qa)"

if [ -z "$help_txt" ] || [ ! -f "$help_txt" ]; then
  echo "failed to locate Neovim runtime help docs" >&2
  exit 1
fi

doc_dir="$(dirname "$help_txt")"
tags_file="$doc_dir/tags"

echo "DOC_DIR: $doc_dir"
echo "TAGS:    $tags_file"

awk_exact() {
  local term="$1"
  awk -F '\t' -v t="$term" '$1 == t { print FNR ":" $0 }' "$tags_file"
}

awk_prefix() {
  local term="$1"
  awk -F '\t' -v t="$term" 'index($1, t) == 1 { print FNR ":" $0 }' "$tags_file" | head -n 20
}

for term in "$@"; do
  echo
  echo "== $term =="

  if [ -f "$tags_file" ]; then
    echo "-- exact tags --"
    awk_exact "$term" || true

    echo "-- prefix tags --"
    awk_prefix "$term" || true
  fi

  echo "-- full-text hits --"
  rg -n --fixed-strings "$term" "$doc_dir"/*.txt | head -n 20 || true
done
