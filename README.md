# dotfiles

Unified NixOS + macOS dotfiles with Home Manager and a small `just`-powered command interface.

## Hosts

- `think` — NixOS ThinkPad
- `mini` — nix-darwin Mac Mini

## System Stack

| Category              | NixOS (`think`)     | macOS (`mini`)     |
| --------------------- | ------------------- | ------------------ |
| **OS**                | NixOS               | macOS + nix-darwin |
| **User Config**       | Home Manager        | Home Manager       |
| **WM/Compositor**     | niri                | Aerospace          |
| **Editor**            | Noctalia + zsh      | zsh                |
| **Bar/Notifications** | Noctalia (built-in) | —                  |
| **Terminal**          | Ghostty             | Ghostty            |
| **Multiplexer**       | Zellij              | Zellij             |
| **Editor**            | Neovim              | Neovim             |
| **Launcher**          | Fuzzel              | Raycast            |

## Management

| Command             | Description                                             |
| ------------------- | ------------------------------------------------------- |
| `ya rebuild`        | Rebuild and switch the current host (shortcut: `ya re`) |
| `ya test`           | Test the current configuration                          |
| `ya rollback`       | Roll back to previous generation                        |
| `ya gc`             | Run garbage collection                                  |
| `ya search <query>` | Search nixpkgs for packages                             |
| `ya update-all`     | Update all flake inputs (shortcut: `ya ua`)             |
| `ya update <input>` | Update specific flake input (shortcut: `ya u <input>`)  |

## Examples

```sh
ya rebuild
ya test
ya update-all
ya update <input>
ya search <query>
```
