{ config, pkgs, dotfilesPath, ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "joohoon";
  home.homeDirectory = "/home/joohoon";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Shell aliases
  programs.bash = {
    enable = true;
    shellAliases = {
      switch = "cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think";
    };
  };

  # Symlink dotfiles from the repo
  # These configs are raw files you edit directly in ~/dotfiles/config/
  home.file = {
    # NixOS-specific
    ".config/niri/config.kdl".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/niri/config.kdl";
    ".config/waybar/config".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/waybar/config";
    ".config/waybar/style.css".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/waybar/style.css";
    ".config/swaylock/config".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/swaylock/config";
    
    # Shared with Mac Mini
    ".config/nvim".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";
    ".config/wezterm".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/wezterm";
    
    # Kime Korean IME config
    ".config/kime/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kime/config.yaml";
  };

  # User packages (NixOS-specific, mostly Wayland related)
  # Common packages (ripgrep, fzf, bat, delta, lazygit, zoxide) are in common.nix
  home.packages = with pkgs; [
    swaylock-effects
    swayidle
    mako
    brightnessctl
    libnotify
    swaybg
  ];
}
