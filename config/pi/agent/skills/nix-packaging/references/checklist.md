# Nix Packaging Checklist

Use this checklist when packaging new software for your Nix dotfiles.

## Phase 1: Discovery (5 mins)

- [ ] Check if package exists in nixpkgs: `nix search nixpkgs#packagename`
- [ ] Check upstream GitHub releases for pre-built binaries
- [ ] Determine supported platforms (Linux x86_64, Darwin arm64, etc.)
- [ ] Note the latest version and download URLs

## Phase 2: Choose Approach

**Choose ONE:**

- [ ] **Pre-built binary** - Fast, works if upstream provides binaries
- [ ] **Build from source** - Use if no binaries or need customization
- [ ] **Overlay** - If nixpkgs has it but outdated
- [ ] **Flake input** - If upstream provides a flake.nix

## Phase 3: Create Package

### If Pre-built Binary:
- [ ] Create `pkgs/<name>/default.nix`
- [ ] Copy from `references/binary-template.nix`
- [ ] Define sources for each platform
- [ ] Get hashes with `nix-prefetch-url`
- [ ] Set `sourceRoot` based on tarball structure
- [ ] Test with `nix-build -E 'with import <nixpkgs> {}; callPackage pkgs/<name> {}'`

### If Build from Source (Rust):
- [ ] Create `pkgs/<name>/default.nix`
- [ ] Copy from `references/rust-template.nix`
- [ ] Set `version` and `src` (use `lib.fakeHash` first)
- [ ] Run build to get source hash, update
- [ ] Run build to get `cargoHash`, update
- [ ] Add `doCheck = false` if tests fail
- [ ] Test the build

### If Build from Source (Go):
- [ ] Create `pkgs/<name>/default.nix`
- [ ] Copy from `references/go-template.nix`
- [ ] Set `version`, `src`, `vendorHash`
- [ ] Test the build

## Phase 4: Integration

- [ ] Add to `home/common.nix` (shared) or `home/nixos.nix`/`home/darwin.nix` (specific)
- [ ] Use `pkgs.callPackage ../pkgs/<name> {}` in let block
- [ ] Add to `home.packages` list

## Phase 5: Activation

- [ ] Rebuild: `sudo nixos-rebuild switch --flake .#hostname` (NixOS)
- [ ] Rebuild: `darwin-rebuild switch --flake .#hostname` (Darwin)
- [ ] Test the installed binary: `which <binary>` and `<binary> --version`

## Common Gotchas

| Problem | Quick Fix |
|---------|-----------|
| `hash mismatch` | Use `lib.fakeHash`, rebuild, copy "got:" hash |
| `source root not found` | Check tarball with `tar -tzf`, set `sourceRoot` |
| `libstdc++.so.6 not found` | Add `stdenv.cc.cc.lib` to `buildInputs` |
| Tests fail | Add `doCheck = false;` |
| Darwin build fails | Add `darwin.apple_sdk.frameworks.*` to `buildInputs` |

## Quick Commands

```bash
# Get tarball hash
nix-prefetch-url --type sha256 "https://.../file.tar.gz"

# Get git hash
nix-prefetch-git --url https://github.com/owner/repo --rev v1.0.0

# Test build
cd ~/dotfiles
nix-build -E 'with import <nixpkgs> {}; callPackage pkgs/name {}'

# Check syntax
nix-instantiate --parse pkgs/name/default.nix

# Check result
./result/bin/binary --version
```
