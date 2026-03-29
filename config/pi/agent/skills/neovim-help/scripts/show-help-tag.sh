#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: $0 <exact-tag> [context-lines]" >&2
  exit 1
fi

tag="$1"
context_lines="${2:-${NVIM_HELP_CONTEXT:-8}}"
max_matches="${NVIM_HELP_TAG_MATCHES:-5}"

help_txt="$(nvim --clean --headless '+lua io.write(vim.api.nvim_get_runtime_file("doc/help.txt", false)[1] or "")' +qa)"

if [ -z "$help_txt" ] || [ ! -f "$help_txt" ]; then
  echo "failed to locate Neovim runtime help docs" >&2
  exit 1
fi

doc_dir="$(dirname "$help_txt")"
tags_file="$doc_dir/tags"

if [ ! -f "$tags_file" ]; then
  echo "missing tags file: $tags_file" >&2
  exit 1
fi

candidate_tags() {
  local term="$1"
  printf '%s\n' "$term"

  if [[ "$term" =~ ^[A-Za-z0-9_.-]+$ ]]; then
    printf "'%s'\n" "$term"
  fi
}

find_matching_tags() {
  local term="$1"
  local candidate

  while IFS= read -r candidate; do
    awk -F '\t' -v t="$candidate" '$1 == t { print $1 "\t" $2 "\t" $3 }' "$tags_file"
  done < <(candidate_tags "$term") | awk '!seen[$0]++' | head -n "$max_matches"
}

matches="$(find_matching_tags "$tag")"

if [ -z "$matches" ]; then
  echo "No exact tag match for: $tag"
  echo
  echo "Prefix suggestions:"
  while IFS= read -r candidate; do
    awk -F '\t' -v t="$candidate" 'index($1, t) == 1 { print $1 "\t" $2 }' "$tags_file"
  done < <(candidate_tags "$tag") | awk '!seen[$0]++' | head -n 20 || true
  exit 1
fi

echo "DOC_DIR: $doc_dir"
echo "QUERY:   $tag"
echo "CONTEXT: +/-${context_lines} lines"

while IFS=$'\t' read -r matched_tag rel_file excmd; do
  [ -n "$matched_tag" ] || continue
  file="$doc_dir/$rel_file"

  needle="$matched_tag"
  if [ -n "${excmd:-}" ] && [[ "$excmd" == /* ]]; then
    needle="${excmd#/}"
  fi

  hit="$(rg -n -m 1 --fixed-strings "$needle" "$file" || true)"
  if [ -z "$hit" ] && [ "$needle" != "$matched_tag" ]; then
    hit="$(rg -n -m 1 --fixed-strings "$matched_tag" "$file" || true)"
  fi

  echo
  echo "== $matched_tag ($rel_file) =="

  if [ -z "$hit" ]; then
    echo "Could not find tag anchor in file; inspect file manually."
    continue
  fi

  line="${hit%%:*}"
  start=$(( line > context_lines ? line - context_lines : 1 ))
  end=$(( line + context_lines ))
  awk -v start="$start" -v end="$end" 'NR >= start && NR <= end { printf "%d:%s\n", NR, $0 }' "$file"
done <<< "$matches"
