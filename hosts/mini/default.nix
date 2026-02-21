{
  pkgs,
  lib,
  config,
  inputs,
  username,
  system,
  ...
}:
let
  overlays = [
    (import ../../overlays)
  ];
in
{
  users.users.${username} = {
    home = "/Users/${username}";
    name = "${username}";
  };

  nixpkgs.overlays = overlays;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.home-manager
    pkgs.nixfmt-rfc-style
    pkgs.neovim
    pkgs.aerospace
    pkgs.docker
    pkgs.docker-compose
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # https://github.com/LnL7/nix-darwin/issues/740
  nix.settings.extra-nix-path = "nixpkgs=flake:nixpkgs";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = system;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "aldente"
      "mos"
      "discord"
      "1password-cli"
    ];
}
