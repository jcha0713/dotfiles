# Noctalia Plugin Setup Guide

Quick reference for adding Noctalia plugins to the NixOS system.

## Overview

Noctalia plugins are downloaded from the [noctalia-plugins](https://github.com/noctalia-dev/noctalia-plugins) repository and installed via custom Nix packages.

## Steps

### 1. Create the package

```bash
mkdir -p pkgs/<plugin-name>
```

`pkgs/<plugin-name>/default.nix`:

```nix
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "noctalia-<plugin-name>";
  version = "unstable-YYYY-MM-DD";

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-plugins";
    rev = "main";
    hash = "sha256-PLACEHOLDER";  # Use lib.fakeHash first, then copy "got:" hash
  };

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/noctalia/plugins
    cp -r $src/<plugin-name> $out/share/noctalia/plugins/
  '';

  meta = {
    description = "Brief description";
    license = lib.licenses.mit;
  };
}
```

### 2. Install and symlink in `home/nixos.nix`

```nix
let
  noctalia-<plugin-name> = pkgs.callPackage ../pkgs/noctalia-<plugin-name> {};
in
{
  home.packages = [ noctalia-<plugin-name> ];

  home.file.".local/share/noctalia/plugins/<plugin-name>".source =
    "${noctalia-<plugin-name>}/share/noctalia/plugins/<plugin-name>";
}
```

### 3. Enable in bar (`home/noctalia.nix`)

```nix
settings.bar.widgets.right = [
  { id = "plugin:<plugin-name>"; }  # Note: plugin: prefix required!
  # ... other widgets
];

# Optional: plugin-specific settings
pluginSettings = {
  <plugin-name> = {
    settingKey = value;
  };
};
```

### 4. Rebuild

```bash
cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think
```

## Important: The `plugin:` Prefix

Plugin widgets **must** use the `plugin:<name>` format in the widget ID.

| Correct          | Incorrect |
| ---------------- | --------- |
| `plugin:catwalk` | `catwalk` |

Without the prefix, Noctalia logs:

```
WARN qml: Settings !!! Deleted invalid bar widget catwalk !!!
```

Built-in widgets like `Tray`, `Clock`, `Workspace` do **not** use the prefix.

## Example: Catwalk Plugin

See the actual implementation in the dotfiles:

- **Package:** `pkgs/noctalia-catwalk/default.nix`
- **NixOS integration:** `home/nixos.nix` (lines with `noctalia-catwalk`)
- **Bar configuration:** `home/noctalia.nix` (search for `plugin:catwalk`)

## Troubleshooting

### IPC target not found (`plugin:<name>`)

- IPC handlers are registered only if the plugin `Main.qml` is loaded.
- Check targets with `noctalia-shell ipc show`.
- If missing, ensure `manifest.json` has `"main": "Main.qml"` and `Main.qml` defines `IpcHandler { target: "plugin:<name>" }`.

### Home Manager error: `settings.json ... outside $HOME`

- Avoid symlinking entire plugin dirs with writable `settings.json` into `~/.config/noctalia/plugins/<name>`.
- In this dotfiles setup:
  - keep normal plugins in `~/.local/share/noctalia/plugins/...`
  - only place plugins requiring direct Noctalia config loading (like custom IPC sticky-notes) in `~/.config/noctalia/plugins/...`

### Widget not appearing

1. Check logs: `journalctl --user -u noctalia-shell -n 50 | grep -i <plugin-name>`
2. Verify plugin loaded: Look for `Registered plugin widget: plugin:<name>`
3. Check for "Deleted invalid bar widget" - indicates missing `plugin:` prefix

### Getting the hash

Use `lib.fakeHash` initially, then copy the "got:" hash from the build error:

```nix
hash = lib.fakeHash;
```
