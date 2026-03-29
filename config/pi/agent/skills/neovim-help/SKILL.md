---
name: neovim-help
description: Search local Neovim help docs. Use when the user asks about Neovim, nvim, :help tags, options, autocmds, Lua API, LSP, diagnostics, treesitter, keymaps, plugin management, or nightly/version-specific behavior.
---

# Neovim Help

Use local Neovim help before answering Neovim questions from memory.

Skill directory: the directory containing this `SKILL.md` file.

When this skill references a relative path like `scripts/show-help-tag.sh`, resolve it against the skill directory. Do not assume the current working directory is the skill directory.

## When triggered

For Neovim-related questions:

1. Search the installed local help docs first.
2. Prefer exact help tags when possible.
3. Read the matching help file sections before answering.
4. For version or compatibility questions, also check `news.txt` and `deprecated.txt`.
5. Base answers on the currently installed local runtime docs, which may differ from stable online docs if the user is on nightly.

## Search workflow

1. Extract 1-3 likely help terms from the question.
   - Examples: `vim.lsp.config()`, `lsp-config`, `LspAttach`, `autocmd`, `:autocmd`, `vim.pack`, `diagnostic`, `treesitter`
2. If the question is about a config value that embeds commands, expressions, or format items, decompose it into subterms and search those too.
   - Example: for `keywordprg=':vertical botright help'`, search `keywordprg`, `K`, `:vertical`, `:botright`, `:help`
   - Example: for `rulerformat='%Ll %l:%c %p%%'`, search `rulerformat`, `statusline`, `%L`, `%l`, `%c`, `%p`
3. Resolve the local runtime help directory once, then search it directly with your own terms.

```bash
help_txt="$(nvim --clean --headless '+lua io.write(vim.api.nvim_get_runtime_file("doc/help.txt", false)[1] or "")' +qa)"
doc_dir="$(dirname "$help_txt")"
rg -n --fixed-strings 'autocmd' "$doc_dir"/*.txt
```

4. If you already know the exact help tag, use the exact-tag helper:

```bash
scripts/show-help-tag.sh 'keywordprg'
scripts/show-help-tag.sh ':vertical'
```

5. Use the reported file paths and context to `read` the relevant sections.
6. Answer with the help tags and files you relied on.

## Fallback rules

- Function tags often include `()` in the tags file, e.g. `vim.lsp.config()`.
- Some conceptual topics also have a shorter tag, e.g. `lsp-config`.
- Command docs may exist both as a command tag and a topic tag, e.g. `:autocmd` and `autocmd`.
- Short or symbol-heavy searches can be noisy. For items like `%L`, `%l`, `%c`, `%p`, `K`, or `%`-style format atoms, search the broader topic such as `statusline`, `rulerformat`, `keywordprg`, or the containing option and inspect the item table.
- For nightly behavior, search terms in `news.txt` and `deprecated.txt` too.

## Tooling notes

### `scripts/show-help-tag.sh`

- Looks up an exact help tag from the local `tags` file and prints nearby section context
- Good when you already know the precise tag to inspect

Usage:

```bash
scripts/show-help-tag.sh '<exact-tag>'
scripts/show-help-tag.sh '<exact-tag>' 12
```

## Examples

First resolve the runtime help directory:

```bash
help_txt="$(nvim --clean --headless '+lua io.write(vim.api.nvim_get_runtime_file("doc/help.txt", false)[1] or "")' +qa)"
doc_dir="$(dirname "$help_txt")"
```

### LSP config question

```bash
rg -n --fixed-strings 'vim.lsp.config()' "$doc_dir"/*.txt
rg -n --fixed-strings 'vim.lsp.enable()' "$doc_dir"/*.txt
rg -n --fixed-strings 'lsp-config' "$doc_dir"/*.txt
```

### Autocommand question

```bash
rg -n --fixed-strings ':autocmd' "$doc_dir"/*.txt
rg -n --fixed-strings 'autocmd' "$doc_dir"/*.txt
rg -n --fixed-strings 'nvim_create_autocmd()' "$doc_dir"/*.txt
```

### Version-compatibility question

```bash
rg -n --fixed-strings 'deprecated-0.12' "$doc_dir"/deprecated.txt "$doc_dir"/news*.txt
rg -n --fixed-strings 'vim.diagnostic.jump()' "$doc_dir"/*.txt
```

### Config-value interpretation question

```bash
rg -n --fixed-strings 'keywordprg' "$doc_dir"/*.txt
scripts/show-help-tag.sh 'K'
scripts/show-help-tag.sh ':vertical'
scripts/show-help-tag.sh ':help'

rg -n --fixed-strings 'rulerformat' "$doc_dir"/*.txt
rg -n --fixed-strings 'statusline' "$doc_dir"/*.txt
```

### Exact-tag inspection

```bash
scripts/show-help-tag.sh 'keywordprg'
scripts/show-help-tag.sh ':help'
```
