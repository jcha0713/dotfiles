# Common Nix/Home-Manager Patterns

## Symlinking Configs

### NixOS Pattern

```nix
home.file = {
  ".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";
};
```

### Darwin Pattern

```nix
xdg.configFile = {
  nvim.source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim";
};
```

**Why `mkOutOfStoreSymlink`?** Regular `source` copies files to the Nix store (read-only). Symlinks allow live editing.

## Theme System

### Defining a Theme

```nix
# lib/themes/palettes.nix
my-theme = {
  name = "my-theme";
  variant = "dark";  # or "light"
  colors = {
    bg = "#0d0d0d";
    fg = "#f5f2ed";
    # ... ANSI colors
  };
};
```

### Using a Theme

```nix
# home/nixos.nix
let
  palettes = import ../lib/themes/palettes.nix;
  activeThemeName = "e-ink-dark";  # Change this
  activeTheme = palettes.${activeThemeName};
  c = activeTheme.colors;
in {
  # Generate config with theme colors
  home.file.".config/swaylock/config".text = ''
    color=${c.bg}
    ring-color=${c.fg}
  '';
}
```

## Conditional Platform Logic

### In Home Manager

```nix
{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = with pkgs; [
    # Common packages
  ] ++ lib.optionals isLinux [
    # Linux-only
    swaylock-effects
  ] ++ lib.optionals isDarwin [
    # macOS-only
    darwin.trash
  ];
}
```

### In Flake

```nix
nixosConfigurations.think = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [ ./hosts/think ];
};

darwinConfigurations.mini = nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [ ./hosts/mini ];
};
```

## Custom Scripts

### Nix Expression Pattern

```nix
# scripts/my-script.nix
{ pkgs }:

pkgs.writeShellApplication {
  name = "my-script";
  runtimeInputs = with pkgs; [ fzf jq ];  # Dependencies
  text = builtins.readFile ./my-script.sh;
}
```

Then add to packages:

```nix
home/packages = [
  (import ../scripts/my-script.nix { inherit pkgs; })
];
```

## Overlays

Custom packages via overlays:

```nix
# overlays/default.nix
final: prev: {
  my-package = prev.callPackage ./packages/my-package.nix {};
}
```

Add to flake:

```nix
nixpkgs = {
  url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  overlays = [ ./overlays ];
};
```

## Home Manager Modules

### Splitting Config

```nix
# home/nixos.nix
{
  imports = [
    ./common.nix
    ./zsh.nix
    ./git.nix
  ];
}
```

### Passing Special Args

```nix
nixosConfigurations.think = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = {
        dotfilesPath = "/home/joohoon/dotfiles";
      };
    }
  ];
};
```

Then access in home config:

```nix
{ config, pkgs, dotfilesPath, ... }: {
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";
}
```
