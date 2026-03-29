---
name: nix-packaging
description: Package software for Nix when it's missing from nixpkgs or outdated. Covers pre-built binaries, Rust/Go/Node projects, and multi-platform derivations.
---

# Nix Packaging Guide

Workflow for adding new or updated software to a Nix flake-based dotfiles setup.

## Decision Tree

```
Is the package in nixpkgs?
├── No → Check upstream GitHub releases for pre-built binaries
│   ├── Yes (Linux/macOS binaries available) → Use pre-built binary approach
│   └── No → Build from source (Rust/Go/Node/etc.)
└── Yes → Is it outdated?
    ├── No → Use nixpkgs version
    └── Yes → Check upstream releases
        ├── Pre-built binaries? → Use binary approach
        └── Only source? → Custom derivation with src override
```

## Quick Reference

| Situation                          | Approach              | File Location             |
| ---------------------------------- | --------------------- | ------------------------- |
| Missing from nixpkgs, has binaries | Pre-built binary      | `pkgs/<name>/default.nix` |
| Missing from nixpkgs, must build   | Custom build          | `pkgs/<name>/default.nix` |
| Outdated in nixpkgs                | Overlay or custom pkg | `overlays/` or `pkgs/`    |
| Flake available upstream           | Add as flake input    | `flake.nix` inputs        |

## Pre-Built Binary Approach (Fastest)

Use when upstream provides Linux/macOS binaries in GitHub releases.

```nix
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, zlib
}:

let
  inherit (stdenv.hostPlatform) system;

  sources = {
    x86_64-linux = {
      url = "https://github.com/OWNER/REPO/releases/download/vVERSION/PACKAGE-VERSION-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-PLACEHOLDER";
      sourceRoot = "PACKAGE-VERSION-x86_64-unknown-linux-gnu";
    };
    aarch64-darwin = {
      url = "https://github.com/OWNER/REPO/releases/download/vVERSION/PACKAGE-VERSION-aarch64-apple-darwin.tar.gz";
      hash = "sha256-PLACEHOLDER";
      sourceRoot = "PACKAGE-VERSION-aarch64-apple-darwin";
    };
  };

  srcInfo = sources.${system} or (throw "Unsupported system: ${system}");
in
stdenv.mkDerivation rec {
  pname = "package-name";
  version = "X.Y.Z";

  src = fetchurl {
    url = srcInfo.url;
    hash = srcInfo.hash;
  };

  # Linux-only: auto-patch ELF binaries
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    stdenv.cc.cc.lib  # libstdc++.so.6, libgcc_s.so.1
  ];

  dontBuild = true;
  dontConfigure = true;

  sourceRoot = srcInfo.sourceRoot;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp binary-name $out/bin/
    # Optional: create alternative name
    ln -s $out/bin/binary-name $out/bin/alternative-name
    runHook postInstall
  '';

  meta = {
    description = "Brief description";
    homepage = "https://github.com/OWNER/REPO";
    license = lib.licenses.mit;
    mainProgram = "binary-name";
    platforms = builtins.attrNames sources;
  };
}
```

## Build from Source (Rust Example)

```nix
{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "package-name";
  version = "X.Y.Z";

  src = fetchFromGitHub {
    owner = "github-owner";
    repo = "repo-name";
    rev = "v${version}";
    hash = "sha256-PLACEHOLDER";  # Get with nix-prefetch-url or lib.fakeHash
  };

  cargoHash = "sha256-PLACEHOLDER";  # Get with lib.fakeHash, then replace

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  # Skip tests that fail due to environment differences
  doCheck = false;

  meta = {
    description = "Description";
    homepage = "https://github.com/OWNER/REPO";
    license = lib.licenses.mit;
    mainProgram = "binary-name";
  };
}
```

## Getting Hashes

### Method 1: nix-prefetch-url (for tarballs)

```bash
nix-prefetch-url --type sha256 "https://github.com/OWNER/REPO/releases/download/vVERSION/FILE.tar.gz"
```

### Method 2: lib.fakeHash (for development)

```nix
hash = lib.fakeHash;  # or "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
```

Build once, copy the "got" hash from the error message, replace.

### Method 3: nix-prefetch-git (for git sources)

```bash
nix-prefetch-git --url https://github.com/OWNER/REPO --rev vVERSION
```

## Integration with Dotfiles

### Step 1: Create package

```bash
mkdir -p pkgs/<name>
# Write default.nix
```

### Step 2: Add to home configuration

```nix
# home/common.nix (for shared packages)
{ config, pkgs, ... }:

let
  mypackage = pkgs.callPackage ../pkgs/<name>/default.nix {};
in
{
  home.packages = with pkgs; [
    # ... other packages
    mypackage
  ];
}
```

### Step 3: Rebuild

```bash
# NixOS
sudo nixos-rebuild switch --flake .#hostname

# Darwin
darwin-rebuild switch --flake .#hostname
```

## Testing

### Test build directly

```bash
cd ~/dotfiles
nix-build -E 'with import <nixpkgs> {}; callPackage pkgs/<name>/default.nix {}'

# Test the binary
./result/bin/<binary> --version
```

### Check syntax

```bash
nix-instantiate --parse pkgs/<name>/default.nix
```

## Common Issues

| Issue                                     | Solution                                                   |
| ----------------------------------------- | ---------------------------------------------------------- |
| `auto-patchelf: libstdc++.so.6 not found` | Add `stdenv.cc.cc.lib` to `buildInputs`                    |
| `hash mismatch`                           | Use error's "got:" hash, or `lib.fakeHash`                 |
| `source root not found`                   | Set correct `sourceRoot` matching tarball structure        |
| Tests fail                                | Add `doCheck = false;` if tests are environment-sensitive  |
| Darwin build fails                        | Add relevant frameworks from `darwin.apple_sdk.frameworks` |

## References

See `references/` for:

- `binary-template.nix` - Complete pre-built binary template
- `rust-template.nix` - Complete Rust build from source template
- `overlay-example.nix` - Overlay for overriding nixpkgs packages
