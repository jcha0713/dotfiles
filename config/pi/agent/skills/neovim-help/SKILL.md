---
name: neovim-help
description: Search local Neovim help docs. Use when the user asks about Neovim, nvim, :help tags, options, autocmds, Lua API, LSP, diagnostics, treesitter, keymaps, plugin management, or nightly/version-specific behavior.
---

# Neovim Help

Use local Neovim help before answering Neovim questions from memory.

## When triggered

For Neovim-related questions:

1. Search the installed local help docs first.
2. Prefer exact help tags when possible.
3. Read the matching help file sections before answering.
4. For version or compatibility questions, also check `news.txt` and `deprecated.txt`.

## Search workflow

1. Extract 1-3 likely help terms from the question.
   - Examples: `vim.lsp.config()`, `lsp-config`, `LspAttach`, `autocmd`, `:autocmd`, `vim.pack`, `diagnostic`, `treesitter`
2. Run the helper script:

```bash
./scripts/search-help.sh 'vim.lsp.config()' 'lsp-config' 'LspAttach'
```

3. Use the reported file paths and `read` the relevant sections.
4. Answer with the help tags and files you relied on.

## Notes

- Function tags often include `()` in the tags file, e.g. `vim.lsp.config()`.
- Some conceptual topics also have a shorter tag, e.g. `lsp-config`.
- Command docs may exist both as a command tag and a topic tag, e.g. `:autocmd` and `autocmd`.
- For nightly behavior, search terms in `news.txt` and `deprecated.txt` too.

## Examples

### LSP config question

```bash
./scripts/search-help.sh 'vim.lsp.config()' 'vim.lsp.enable()' 'lsp-config'
```

### Autocommand question

```bash
./scripts/search-help.sh ':autocmd' 'autocmd' 'nvim_create_autocmd()'
```

### Version-compatibility question

```bash
./scripts/search-help.sh 'deprecated-0.12' 'vim.diagnostic.jump()' 'news'
```
