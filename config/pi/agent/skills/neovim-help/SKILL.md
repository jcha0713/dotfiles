---
name: neovim-help
description: Search local Neovim help docs. Use when the user asks about Neovim, nvim, :help tags, options, autocmds, Lua API, LSP, diagnostics, treesitter, keymaps, plugin management, or nightly/version-specific behavior.
---

# Neovim Help

Use local Neovim help before answering Neovim questions from memory.

Skill directory: the directory containing this `SKILL.md` file.

When this skill references a relative path like `scripts/search-help.sh`, resolve it against the skill directory. Do not assume the current working directory is the skill directory.

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
3. Run the helper search script:

```bash
scripts/search-help.sh 'vim.lsp.config()' 'lsp-config' 'LspAttach'
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
- Format items like `%L` may not have exact tags; if exact-tag lookup fails, search the broader topic such as `statusline`, `rulerformat`, or the containing option and inspect the item table.
- For nightly behavior, search terms in `news.txt` and `deprecated.txt` too.

## Tooling notes

### `scripts/search-help.sh`

- Searches exact tags, prefix tags, and full-text hits
- Prints deduplicated tag-based context to reduce manual jumping
- Useful for exploratory search and composed settings

Environment variables:

- `NVIM_HELP_CONTEXT`: context lines around each hit (default `3`)
- `NVIM_HELP_MAX_TAGS`: max exact/prefix tags to print (default `5`)
- `NVIM_HELP_MAX_FULLTEXT_HITS`: max full-text hits to print (default `20`)
- `NVIM_HELP_MAX_CONTEXT_BLOCKS`: max contextual file blocks per term (default `3`)

### `scripts/show-help-tag.sh`

- Looks up an exact help tag and prints nearby section context
- Good when you already know the precise tag to inspect

Usage:

```bash
scripts/show-help-tag.sh '<exact-tag>'
scripts/show-help-tag.sh '<exact-tag>' 12
```

## Examples

### LSP config question

```bash
scripts/search-help.sh 'vim.lsp.config()' 'vim.lsp.enable()' 'lsp-config'
```

### Autocommand question

```bash
scripts/search-help.sh ':autocmd' 'autocmd' 'nvim_create_autocmd()'
```

### Version-compatibility question

```bash
scripts/search-help.sh 'deprecated-0.12' 'vim.diagnostic.jump()' 'news'
```

### Config-value interpretation question

```bash
scripts/search-help.sh 'keywordprg' 'K' ':vertical' ':botright' ':help'
scripts/search-help.sh 'rulerformat' 'statusline' '%L' '%l' '%c' '%p'
```

### Exact-tag inspection

```bash
scripts/show-help-tag.sh 'keywordprg'
scripts/show-help-tag.sh ':help'
```
