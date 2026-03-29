{
  config,
  pkgs,
  dotfilesPath,
  ...
}:

let
  noctalia-catwalk = pkgs.callPackage ../pkgs/noctalia-catwalk { };
  noctalia-sticky-notes = pkgs.callPackage ../pkgs/noctalia-sticky-notes { };
  noctalia-pomodoro = pkgs.callPackage ../pkgs/noctalia-pomodoro { };
in
{
  imports = [
    ./common.nix
    ./zsh.nix
    ./noctalia.nix
  ];

  home.username = "joohoon";
  home.homeDirectory = "/home/joohoon";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # NixOS-specific zsh additions
  programs.zsh.shellAliases = {
    switch = "cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think";
    nix-switch = "cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think";
  };

  # Symlink dotfiles from the repo
  home.file = {
    # Noctalia plugins packaged via Nix
    ".local/share/noctalia/plugins/catwalk".source =
      "${noctalia-catwalk}/share/noctalia/plugins/catwalk";
    ".local/share/noctalia/plugins/pomodoro".source =
      "${noctalia-pomodoro}/share/noctalia/plugins/pomodoro";

    # Sticky-notes must live in ~/.config/noctalia/plugins for IPC target registration
    ".config/noctalia/plugins/sticky-notes" = {
      source = "${noctalia-sticky-notes}/share/noctalia/plugins/sticky-notes";
      force = true;
    };
  };

  home.sessionPath = [
    "/home/joohoon/.local/share/bob/nvim-bin"
  ];

  xdg.configFile = {
    niri = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/niri";
    };

    kime = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kime";

    };
  };

  # User packages (NixOS-specific, mostly Wayland related)
  # NOTE: Noctalia replaces: waybar, mako, swaylock, swaybg, swayidle
  home.packages = with pkgs; [
    brightnessctl
    libnotify
    # Clipboard management for Wayland - Noctalia integrates with this
    cliphist
    unzip
    trash-cli
    fastfetch
    vesktop
    # Theme picker (fuzzel GUI) - keep for theme switching
    (import ../scripts/theme-picker-fuzzel.nix { inherit pkgs; })
    # Noctalia plugins
    noctalia-catwalk
    noctalia-sticky-notes
    noctalia-pomodoro
    jq
  ];

}
