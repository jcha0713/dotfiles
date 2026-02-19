{ config, pkgs, dotfilesPath, ... }:

{
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
  xdg.configFile = {
    "niri/config.kdl".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/niri/config.kdl";
    "waybar/config".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/waybar/config";
    "waybar/style.css".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/waybar/style.css";
    "swaylock/config".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/swaylock/config";
  };

  # User packages (NixOS-specific, mostly Wayland related)
  # Common packages should eventually move to home/common.nix
  home.packages = with pkgs; [
    swaylock-effects
    swayidle
    mako
    brightnessctl
    libnotify
    swaybg
  ];
}
