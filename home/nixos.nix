{
  config,
  pkgs,
  dotfilesPath,
  ...
}:

let
  noctalia-catwalk = pkgs.callPackage ../pkgs/noctalia-catwalk {};
  noctalia-todo = pkgs.callPackage ../pkgs/noctalia-todo {};
  noctalia-pomodoro = pkgs.callPackage ../pkgs/noctalia-pomodoro {};
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
    ".pi/agent/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/keybindings.json";
    ".pi/agent/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/settings.json";
    ".pi/agent/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/skills";
    ".pi/agent/extensions".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/extensions";

    # NixOS-specific
    ".config/niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/niri/config.kdl";

    # Shared with Mac Mini
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";
    ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/wezterm";

    # Kime Korean IME config
    ".config/kime/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kime/config.yaml";

    # Ghostty config and themes
    ".config/ghostty/config".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty/config";
    ".config/ghostty/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty/themes";

    # Zellij config
    ".config/zellij/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zellij/config.kdl";

    # Noctalia plugins
    ".local/share/noctalia/plugins/catwalk".source =
      "${noctalia-catwalk}/share/noctalia/plugins/catwalk";
    ".local/share/noctalia/plugins/todo".source =
      "${noctalia-todo}/share/noctalia/plugins/todo";
    ".local/share/noctalia/plugins/pomodoro".source =
      "${noctalia-pomodoro}/share/noctalia/plugins/pomodoro";
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
    # Todo quick add via fuzzel
    (import ../scripts/fuzzel-todo.nix { inherit pkgs; })
    # Noctalia plugins
    noctalia-catwalk
    noctalia-todo
    noctalia-pomodoro
  ];

}
