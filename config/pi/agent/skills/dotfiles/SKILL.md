---
name: dotfiles
description: Navigate and modify Nix-based dotfiles with flakes and home-manager. Use when working with nix configs, finding where settings live, or understanding the repository structure.
---

# Dotfiles Navigation

Unified NixOS + macOS configuration using Nix flakes and Home Manager.

## Entry Points

| File | Purpose |
|------|---------|
| `flake.nix` | System definitions (`think` = NixOS, `mini` = Darwin) |
| `home/common.nix` | Shared packages and programs (git, delta, zoxide, lazygit, yazi) |
| `home/zsh.nix` | Shared zsh configuration (imported by nixos.nix and darwin.nix) |
| `home/nixos.nix` | ThinkPad-specific (Noctalia, niri, ghostty) |
| `home/darwin.nix` | Mac Mini-specific (aerospace, karabiner, hammerspoon, espanso) |
| `home/noctalia.nix` | Noctalia shell configuration (bar, notifications, lock screen) |
| `hosts/think/default.nix` | NixOS system config |
| `hosts/mini/default.nix` | Darwin system config |

## Directory Conventions

**Configs are symlinked from `config/` - edit there, NOT in `~/.config/`:**
- Shared: `nvim/`, `zellij/`, `wezterm/`, `zsh/`
- NixOS only: `niri/`, `waybar/`, `ghostty/`, `mako/`, `swaylock/`
- macOS only: `aerospace/`, `karabiner/`, `hammerspoon/`, `espanso/`

## Finding Things

**To find where a config lives:**
1. Check `home/common.nix` for shared tools
2. Check `home/nixos.nix` or `home/darwin.nix` for platform-specific
3. Check `config/<tool>/` for raw configs
4. Search: `rg "<tool>" home/ config/ --type nix`

**To find where packages are defined:**
- Shared: `home/common.nix` → `home.packages`
- NixOS: `home/nixos.nix` → `home.packages`
- macOS: `home/darwin.nix` → `home.packages`

## Key Patterns

### Symlinking (used throughout)
```nix
home.file.".config/<tool>".source = 
  config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/<tool>";
```

### Theme System
- Defined in: `lib/themes/palettes.nix`
- Active theme set in: `home/nixos.nix` → `activeThemeName`
- Used by: Ghostty, swaylock (generated config)

### Platform Detection
```nix
{ pkgs, ... }:
let isDarwin = pkgs.stdenv.isDarwin;
in { }
```

### Noctalia Plugin Widgets
When adding plugin widgets to the bar, use the `plugin:` prefix in the widget ID:

```nix
# home/noctalia.nix
settings.bar.widgets.right = [
  { id = "plugin:catwalk"; }  # Note the "plugin:" prefix
  { id = "Tray"; }
  { id = "Volume"; }
];
```

Without the prefix, Noctalia will log: `Deleted invalid bar widget catwalk` and the widget won't appear. Built-in widgets like `Tray`, `Clock`, `Workspace` don't use the prefix.

## Commands (via `ya`)

These dotfiles include a custom `just`-powered command interface at `bin/ya`.

| Command | Description |
| ------- | ----------- |
| `ya rebuild` | Rebuild and switch (shortcut: `ya re`) |
| `ya test` | Test configuration without switching |
| `ya rollback` | Roll back to previous generation |
| `ya gc` | Run garbage collection |
| `ya search <query>` | Search nixpkgs |
| `ya update-all` | Update all flake inputs (shortcut: `ya ua`) |
| `ya update <input>` | Update specific input (shortcut: `ya u <input>`) |

### `ya` Architecture

- **Entry point**: `bin/ya` - main justfile with shebang
- **Modules**: `bin/ya.d/*.just` - imported command modules
- **Shared vars**: `bin/ya.d/common.just` - ROOT, flake_host, is_darwin
- **Nix wrapper**: Defined in `home/common.nix` as `lib.hiPrio` package to shadow yazi's `ya`
- **Yazi helper**: Available as `yaz` (yazi's original `ya` binary)

### Adding New Commands

1. Add recipe to existing module in `bin/ya.d/`
2. Or create new module: `bin/ya.d/<name>.just`
3. Import it in `bin/ya`: `import 'ya.d/<name>.just'`
4. Use shared variables from `common.just`: `{{ROOT}}`, `{{flake_host}}`

### Fallback (raw nix)

```bash
# NixOS
sudo nixos-rebuild switch --flake .#think

# macOS
darwin-rebuild switch --flake .#mini

# Update flake.lock
nix flake update
```

## When Unsure

**Search the codebase rather than trusting this guide:**
```bash
# Find where a tool is configured
rg "programs\.lazygit|lazygit" home/

# Find package definitions
rg "pkgs\.lazygit" home/

# Find config symlinks
rg "config/nvim" home/
```

## References

- `references/nix-patterns.md` - Reusable code patterns
- `references/platform-notes.md` - Platform-specific quirks
- `references/noctalia-plugins.md` - Guide for adding Noctalia plugins
- `references/structure.md` - Auto-generated full structure (see Maintenance)

## Maintenance

This skill is intentionally minimal. Verify with:
- `scripts/verify-structure.sh` - Checks if documented paths exist
- `scripts/generate-structure.sh` - Updates `references/structure.md`

**If this skill seems out of date:**
1. Trust the actual files over this documentation
2. Use `rg` to find current locations
3. Update the skill via `scripts/generate-structure.sh`
