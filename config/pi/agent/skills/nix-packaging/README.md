# Nix Packaging Skill

A Pi skill for packaging software in Nix when it's missing from nixpkgs or outdated.

## What It Covers

- **Pre-built binaries** - Fastest approach when upstream provides releases
- **Build from source** - Rust, Go, and other compiled languages
- **Multi-platform support** - Linux x86_64, macOS arm64/x86_64
- **Integration** - Adding packages to your flake-based dotfiles

## When to Use

Use this skill when:
- You discover a new CLI tool not in nixpkgs
- A package in nixpkgs is outdated and you need the latest
- You want to package your own software

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill documentation and workflow |
| `references/binary-template.nix` | Template for pre-built binaries |
| `references/rust-template.nix` | Template for Rust builds |
| `references/go-template.nix` | Template for Go builds |
| `references/overlay-example.nix` | Example of overriding nixpkgs |
| `references/checklist.md` | Step-by-step packaging checklist |

## Installation

Place this directory in your Pi skills path:
```bash
~/.pi/agent/skills/nix-packaging/
```

Or load explicitly:
```bash
pi --skill /path/to/nix-packaging
```

## Quick Start

1. **Check if binary releases exist** - Go to the GitHub releases page
2. **Copy the appropriate template** from `references/`
3. **Fill in placeholders** - Version, URLs, hashes
4. **Test the build** - `nix-build -E '...'`
5. **Add to your config** - `home/common.nix` or platform-specific
6. **Rebuild and enjoy** - `nixos-rebuild switch` or `darwin-rebuild switch`

## Examples from This Session

The skill was developed while packaging [octorus](https://github.com/ushironoko/octorus):
- Discovered: nixpkgs had v0.3.5, upstream was at v0.5.1
- Upstream provided binaries for Linux and macOS
- Used pre-built binary approach (10 seconds vs 15 minutes building)
- Result: `pkgs/octorus/default.nix` with multi-platform support
