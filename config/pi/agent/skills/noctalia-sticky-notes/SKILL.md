---
name: noctalia-sticky-notes
description: Control Noctalia Sticky Notes via IPC on this NixOS setup. Use when asked to add, list, update, remove, clear, or toggle sticky notes.
---

# Noctalia Sticky Notes IPC

Use `noctalia-shell ipc` commands (not `qs -c ...`) in this environment.

## Quick health check

```bash
noctalia-shell ipc show | rg "^target plugin:sticky-notes$"
```

If missing:

1. `systemctl --user restart noctalia-shell`
2. Re-check `noctalia-shell ipc show`
3. Verify plugin files exist at `~/.config/noctalia/plugins/sticky-notes`

## Commands

```bash
# Add note (returns noteId)
noctalia-shell ipc call plugin:sticky-notes addNote "Buy milk"

# List notes (JSON)
noctalia-shell ipc call plugin:sticky-notes getNotes

# Update note
noctalia-shell ipc call plugin:sticky-notes updateNote "note_123" "Updated text"

# Remove note
noctalia-shell ipc call plugin:sticky-notes removeNote "note_123"

# Clear all notes
noctalia-shell ipc call plugin:sticky-notes clearNotes

# Toggle panel
noctalia-shell ipc call plugin:sticky-notes togglePanel
```

## Markdown support (use in note content)

Sticky Notes renders Markdown. You can include things like:

- headings: `# Title`
- emphasis: `**bold**`, `*italic*`, `~~done~~`
- task lists: `- [ ] todo`, `- [x] done`
- code: `` `inline` `` and fenced blocks
- links/images: `[label](url)`, `![alt](url)`
- tables and blockquotes

Example:

````bash
noctalia-shell ipc call plugin:sticky-notes addNote $'# Today\n- [ ] Review PR\n- [x] Rebuild\n\n```sh\nnoctalia-shell ipc show\n```'
````

## Useful jq helpers

```bash
# Pretty list (newest first)
noctalia-shell ipc call plugin:sticky-notes getNotes \
  | jq -r 'sort_by(.modified) | reverse[] | "\(.noteId)\t\(.content)"'

# Get latest note id
noctalia-shell ipc call plugin:sticky-notes getNotes \
  | jq -r 'sort_by(.modified) | last | .noteId'
```
