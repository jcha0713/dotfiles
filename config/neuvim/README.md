# neuvim

This directory is the rewrite target for a new Neovim configuration that should be:

- modern in style
- understandable from `:help`
- conservative about deprecated APIs
- compatible with Neovim `v0.12.0` nightly

The legacy configuration lives in `config/nvim/`.

## Current state

- `config/neuvim/init.lua` is intentionally empty.
- `config/nvim/` is the source of truth for existing behavior.
- This README is the migration notebook: we record what the old config does, what Neovim help says, and which direction we choose.

## What the legacy config looks like

The old config is a fairly large Lua setup organized like this:

- bootstrap in `config/nvim/init.lua`
- general modules in `config/nvim/lua/modules/`
  - `globals.lua`
  - `options.lua`
  - `keymappings.lua`
  - `autocmd.lua`
  - `lsp/*.lua`
  - `custom/*.lua`
- plugin specs in `config/nvim/lua/plugins/*.lua`
- filetype overrides in `config/nvim/filetype.lua`
- ftplugins in `config/nvim/after/ftplugin/*.lua`
- snippets in `config/nvim/snippets/`

High-level observations:

1. The config is plugin-heavy.
   - many plugin spec files
   - heavy use of lazy-loading
   - multiple overlapping UX plugins
2. LSP is configured in the pre-0.12 style.
   - `require("lspconfig").<server>.setup(...)`
   - shared `on_attach` and capabilities
   - Mason installs servers/tools dynamically
3. A lot of editor behavior is custom.
   - custom keymaps for movement, LSP, tabs, buffers
   - custom autocommands
   - custom helper modules and personal commands
4. Some parts are already modern enough.
   - `vim.filetype.add()` is already used
   - `vim.keymap.set()` is wrapped by utilities
   - `vim.api.nvim_create_autocmd()` is used widely

## Important findings from Neovim help

These are the main help topics guiding the rewrite.

### 1. Built-in LSP config is now first-class

Relevant help:

- `:help lsp-quickstart`
- `:help lsp-config`
- `:help vim.lsp.config()`
- `:help vim.lsp.enable()`
- `:help lsp-attach`
- `:help lsp-defaults`

What this means for us:

- Neovim 0.12 has a built-in configuration flow based on `vim.lsp.config()` and `vim.lsp.enable()`.
- We do not need to build the rewrite around `lspconfig.<server>.setup()`.
- Buffer-local LSP behavior should mostly move to `LspAttach`.
- We should start from Neovim's default LSP keymaps and only override when there is a clear reason.

### 2. `vim.pack` exists, but it is still experimental

Relevant help:

- `:help vim.pack`
- `:help vim.pack.add()`
- `:help vim.pack.update()`
- `:help packages`

What this means for us:

- Neovim now ships a built-in plugin manager.
- It is real and usable, but help still labels it experimental.
- It handles install/update/delete well, but it does not replace the higher-level ergonomics of a mature plugin manager by itself.
- Our old config depends a lot on lazy-loading patterns, plugin dependencies, and plugin-specific setup timing.

### 3. Some legacy diagnostic/LSP patterns should be avoided

Relevant help:

- `:help deprecated-0.11`
- `:help deprecated-0.12`
- `:help vim.diagnostic.jump()`

What this means for us:

- old patterns like `vim.diagnostic.goto_prev()` / `goto_next()` should be replaced with `vim.diagnostic.jump()`
- the rewrite should prefer current APIs instead of carrying compatibility shims forward
- we should audit each legacy helper before copying it

### 4. Neovim already provides more defaults than the old config assumes

Relevant help:

- `:help lsp-defaults`
- `:help grr-default`
- `:help gra`
- `:help gri`
- `:help grn`
- `:help grt`

What this means for us:

- many LSP mappings are already defined by Neovim
- the rewrite should not automatically recreate older custom mappings
- we should keep custom mappings only when they improve ergonomics clearly

## Preliminary migration choices

These are the current best choices unless later help/docs push us in another direction.

### Choice 1: use built-in Neovim APIs wherever possible

Preferred primitives:

- `vim.keymap.set()`
- `vim.api.nvim_create_autocmd()`
- `vim.filetype.add()`
- `vim.lsp.config()` / `vim.lsp.enable()`
- `LspAttach`
- `vim.fs.root()` when root detection is needed

### Choice 2: prefer Nix for external tools, not Mason

Because this repository is a Nix-based dotfiles repo, external binaries should preferably be installed declaratively.

Implication:

- language servers, formatters, and linters should ideally come from Nix/Home Manager
- Mason may be removed entirely from the rewrite unless we find a strong reason to keep it

### Choice 3: keep the rewrite smaller than the original

The old config mixes:

- core editing behavior
- plugin setup
- custom workflows
- experiments
- one-off personal commands

The rewrite should separate:

1. core editor behavior
2. LSP/completion/formatting
3. UI/navigation plugins
4. personal extras

Anything non-essential should be added later, not in the first pass.

### Choice 4: plugin manager decision stays pragmatic

Current recommendation:

- use **built-in Neovim features** for config structure and LSP
- but keep the **plugin manager choice pragmatic**

Why:

- `vim.pack` is attractive and modern
- but the current setup is large and plugin-heavy
- `lazy.nvim` is still the lower-risk option for a multi-plugin migration today

So the current leaning is:

- **Phase 1:** rewrite the core config cleanly, possibly still using `lazy.nvim`
- **Phase 2:** reevaluate whether switching plugin management to `vim.pack` is worth it

If the goal becomes “maximum built-in Neovim, even with some rough edges”, then we can choose `vim.pack` deliberately.

## Legacy items that probably should not be copied as-is

These are early red flags from `config/nvim/`.

- lazy.nvim bootstrap code in `init.lua`
- global state stored through `nvim_set_var()` for config tables
- LSP setup via many `lspconfig` server files
- Mason-driven tool installation inside Neovim
- custom LSP keymaps that duplicate new built-in defaults
- deprecated diagnostic navigation helpers
- one-off autocommands that shell out on write without strong isolation
- old compatibility flags like `vim.g.ts_highlight_lua = true`

## Parts of the old config that are worth preserving

- filetype detection in `config/nvim/filetype.lua`
- the overall preference for small Lua modules
- some useful personal keymaps
- custom ftplugins where they stay small and obvious
- formatter/linter intent, but likely with different implementation

## Proposed rewrite order

1. document goals and choices in this README
2. design the directory layout for `config/neuvim/`
3. write minimal `init.lua`
4. move core options/keymaps/autocmds
5. rebuild LSP using `vim.lsp.config()` and `LspAttach`
6. decide completion/formatting/linting stack
7. add only essential plugins
8. migrate personal custom modules one by one

## Initial success criteria

The new config should eventually:

- start cleanly on Neovim nightly 0.12
- avoid deprecated APIs where practical
- be understandable without reading plugin source first
- keep plugin count lower than the legacy setup
- rely on Neovim help for core behavior
- fit naturally into this Nix-based dotfiles repo

## Open questions

1. Plugin manager: `lazy.nvim` first, or `vim.pack` immediately?
2. Completion: stay with `nvim-cmp`, or try a smaller 0.12-friendly stack?
3. Formatting/linting: Conform + nvim-lint, or more LSP-first behavior?
4. File explorer/search UX: which legacy plugins are actually essential?
5. Which custom workflows belong in the core config, and which should become optional extras?

## Next step

Before writing code, we should inventory the old config by category:

- must-keep behavior
- nice-to-have behavior
- obsolete behavior
- behavior now covered by built-in Neovim defaults
