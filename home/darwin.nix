{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home = {
    # The home.stateVersion is similar to system.stateVersion in your main config
    # Don't change this value after setting it
    stateVersion = "23.11";

    sessionVariables = {
      LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.dylib";
      LANG = "en_US.UTF-8";
      ZVM_INIT_MODE = "sourcing"; # SEE: https://github.com/jeffreytse/zsh-vi-mode/issues/277
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#737246";
    };

    sessionPath = [
      "/Users/jcha0713/.local/share/bob/nvim-bin"
    ];

    activation.installWeztermTerminfo = ''
      echo "Installing WezTerm terminfo..."
      tempfile=$(mktemp)
      ${pkgs.curl}/bin/curl -o $tempfile https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo
      ${pkgs.ncurses}/bin/tic -x -o ~/.terminfo $tempfile
      rm $tempfile
    '';

    # file = {
    #   ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/zsh/.zshrc";
    # };

    # Add some basic packages to be managed by Home Manager instead of system-wide
    # Common packages (ripgrep, bat, fd, lazygit, fzf, delta, zoxide) are in common.nix
    packages = with pkgs; [
      _1password-cli
      ast-grep
      catimg
      colima
      comma
      # curl, ncurses, gh, tree, tree-sitter moved to home/common.nix
      darwin.trash
      deno
      fnm
      fx
      git-absorb
      nap
      nb
      pipx
      rustup
      sqlite
      tailscale
      wakeonlan
      zk
      zsh-autosuggestions
      cloudflared
      pm2

      # TUI
      bottom
      circumflex
      w3m

      # GUI
      aldente
      espanso
      mos
      wezterm
    ];
  };

  xdg.configFile = {
    espanso = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/espanso";
    };
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim";
    };
    wezterm = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/wezterm";
    };
    karabiner = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/karabiner";
    };
    aerospace = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/aerospace";
    };
    sprinkles = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/sprinkles";
    };
    hammerspoon = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/hammerspoon";
    };
    "yazi/flavors/kenso-zen.yazi" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/yazi/flavors/kenso-zen.yazi";
    };
    opencode = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/opencode";
    };
    zellij = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/zellij";
    };
  };

  imports = [
    ./common.nix
    ./zsh.nix
  ];

  # Platform-specific zsh additions for macOS
  programs.zsh.initContent =
    # zsh
    ''
      eval "$(fnm env --use-on-cd --shell zsh)"

      # POKE CLI API
      if [ -e "$HOME"/.config/env/poke ]; then
        export POKE=$(cat "$HOME"/.config/env/poke)
      fi

      # opencode
      export PATH=/Users/jcha0713/.opencode/bin:$PATH

      # bird CLI secrets (local, not tracked by git)
      [[ -f ~/.bird_secrets ]] && source ~/.bird_secrets

      export PATH="$HOME/dev/active/sol-translate/target/release:$PATH"
      export PATH="$HOME/dev/sandbox/sol/target/release:$PATH"
    '';

}
