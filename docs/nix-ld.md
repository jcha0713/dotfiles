# nix-ld on NixOS

## What `nix-ld` does

`nix-ld` is a compatibility layer for running **prebuilt, dynamically linked Linux binaries** on NixOS.

Many binaries downloaded outside of Nix expect a traditional Linux filesystem layout, such as:

- a dynamic loader at `/lib64/ld-linux-x86-64.so.2`
- shared libraries in standard locations like `/lib` or `/usr/lib`

NixOS does not use that layout. Instead, libraries live in unique paths under `/nix/store/...`.

Because of that mismatch, a generic Linux binary may fail to start on NixOS even if the binary itself is otherwise fine. `nix-ld` provides the compatibility needed for those binaries to start and find the runtime libraries they expect.

---

## What problem it solves

Without `nix-ld`, prebuilt binaries often fail with errors like:

```text
Could not start dynamically linked executable
NixOS cannot run dynamically linked executables intended for generic
linux environments out of the box.
```

This usually means the binary expects a loader path or runtime library layout that does not exist on NixOS.

---

## When you need `nix-ld`

You usually need `nix-ld` when you are running software that was **not packaged by Nix**.

Common examples:

- binaries downloaded directly from GitHub releases
- version managers that fetch upstream binaries
- third-party CLI tools installed outside nixpkgs
- vendor-provided Linux binaries

Typical tools that may need it:

- `bob` for Neovim
- `mise`, `asdf`, or similar version managers
- random tarball/zip-based CLI installs

If a downloaded binary fails with linker or shared library errors on NixOS, `nix-ld` is one of the first things to try.

---

## When you usually do **not** need it

You usually do **not** need `nix-ld` when:

- the program is installed from `nixpkgs`
- the binary was built specifically for NixOS
- the package has already been patched properly by Nix

For Nix-managed packages, the runtime paths are already set up correctly.

---

## Example: `bob` + Neovim

In this dotfiles repo, `bob` installs Neovim under:

- `~/.local/share/bob/<version>/bin/nvim`
- with a symlinked launcher in `~/.local/share/bob/nvim-bin`

Home Manager already adds that launcher path to `PATH`, so if `nvim` is found but fails with a dynamic linking error, the issue is **not** PATH.

It means the downloaded Neovim binary is a generic Linux binary and needs compatibility help to run on NixOS. Enabling `nix-ld` fixes that while still letting `bob` manage Neovim versions.
