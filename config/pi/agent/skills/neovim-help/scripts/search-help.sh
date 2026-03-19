#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: $0 <term> [<term> ...]" >&2
  exit 1
fi

context_lines="${NVIM_HELP_CONTEXT:-3}"
max_tags="${NVIM_HELP_MAX_TAGS:-5}"
max_fulltext_hits="${NVIM_HELP_MAX_FULLTEXT_HITS:-20}"
max_context_blocks="${NVIM_HELP_MAX_CONTEXT_BLOCKS:-3}"

help_txt="$(nvim --clean --headless '+lua io.write(vim.api.nvim_get_runtime_file("doc/help.txt", false)[1] or "")' +qa)"

if [ -z "$help_txt" ] || [ ! -f "$help_txt" ]; then
  echo "failed to locate Neovim runtime help docs" >&2
  exit 1
fi

doc_dir="$(dirname "$help_txt")"
tags_file="$doc_dir/tags"

candidate_tags() {
  local term="$1"
  printf '%s\n' "$term"
  if [[ "$term" =~ ^[A-Za-z0-9_.-]+$ ]]; then
    printf "'%s'\n" "$term"
  fi
}

tag_lines() {
  local mode="$1"
  local term="$2"
  while IFS= read -r candidate; do
    case "$mode" in
      exact)
        awk -F '\t' -v t="$candidate" '$1 == t { print FNR ":" $0 }' "$tags_file"
        ;;
      prefix)
        awk -F '\t' -v t="$candidate" 'index($1, t) == 1 { print FNR ":" $0 }' "$tags_file"
        ;;
      *)
        echo "unknown mode: $mode" >&2
        return 1
        ;;
    esac
  done < <(candidate_tags "$term") | awk '!seen[$0]++' | head -n "$max_tags"
}

tag_files() {
  local term="$1"
  while IFS= read -r candidate; do
    awk -F '\t' -v t="$candidate" '$1 == t || index($1, t) == 1 { print $2 }' "$tags_file"
  done < <(candidate_tags "$term") | awk '!seen[$0]++' | head -n "$max_context_blocks"
}

first_hit() {
  local term="$1"
  local file="$2"
  local candidate
  while IFS= read -r candidate; do
    local hit
    hit="$(rg -n -m 1 --fixed-strings "$candidate" "$file" || true)"
    if [ -n "$hit" ]; then
      printf '%s\n' "$hit"
      return 0
    fi
  done < <(candidate_tags "$term")
  return 1
}

print_context() {
  local term="$1"
  local file="$2"
  local label="$3"
  local hit
  hit="$(first_hit "$term" "$file" || true)"
  [ -n "$hit" ] || return 0

  local line start end
  line="${hit%%:*}"
  start=$(( line > context_lines ? line - context_lines : 1 ))
  end=$(( line + context_lines ))

  echo "$label"
  awk -v start="$start" -v end="$end" 'NR >= start && NR <= end { printf "%d:%s\n", NR, $0 }' "$file"
}

echo "DOC_DIR: $doc_dir"
echo "TAGS:    $tags_file"
echo "CONTEXT: +/-${context_lines} lines"
echo

echo "Tip: use scripts/show-help-tag.sh '<exact-tag>' for direct section lookup."

for term in "$@"; do
  echo
  echo "== $term =="

  if [ -f "$tags_file" ]; then
    echo "-- exact tags --"
    tag_lines exact "$term" || true

    echo "-- prefix tags --"
    tag_lines prefix "$term" || true

    echo "-- tag context --"
    found_context=0
    while IFS= read -r rel_file; do
      [ -n "$rel_file" ] || continue
      found_context=1
      print_context "$term" "$doc_dir/$rel_file" "context: $rel_file"
    done < <(tag_files "$term")
    if [ "$found_context" -eq 0 ]; then
      echo "context: (none)"
    fi
  fi

  echo "-- full-text hits --"
  rg -n --fixed-strings "$term" "$doc_dir"/*.txt | head -n "$max_fulltext_hits" || true

  echo "-- full-text context --"
  rg -n -m "$max_context_blocks" -C "$context_lines" --fixed-strings "$term" "$doc_dir"/*.txt || true
done
