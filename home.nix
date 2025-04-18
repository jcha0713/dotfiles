{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home = {
    # The home.stateVersion is similar to system.stateVersion in your main config
    # Don't change this value after setting it
    stateVersion = "23.11";

    sessionVariables = {
      LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.dylib";
    };

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
    packages = with pkgs; [
      bat fd ripgrep
      fzf bottom lazygit
      zk circumflex darwin.trash
      catimg wakeonlan tree
      nap

      # Development tools
      git gh git-absorb
      fnm pnpm deno
      rustup gleam tree-sitter
      sqlite curl ncurses
      tailscale

      # GUI
      aldente mos raycast
      discord espanso wezterm
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
  };

  programs.neovim = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "jcha0713";
    userEmail = "joocha0713@gmail.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;  
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = import ./config/zsh/aliases.nix;
    oh-my-zsh = {
      enable = true;
      theme = "kolo";
    };
    initExtra = /* zsh */ ''
      eval "$(fnm env --use-on-cd --shell zsh)"

      source ${config.home.homeDirectory}/dotfiles/config/zsh/zk.zsh
    '';
  };

  programs.fzf = let
    fdCommand = "fd --exclude '.git' --exclude 'node_modules' --exclude 'lua-language-server'";
  in {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = fdCommand;
    defaultOptions = [
      "--height 80%"
      "--preview-window=right,60%,border-rounded"
      "--layout reverse"
      "--border rounded"
      "--margin 1"
      "--bind ctrl-d:preview-page-down,ctrl-u:preview-page-up"
    ];
    fileWidgetCommand = "${fdCommand} --type f";
    fileWidgetOptions = [
      "--preview 'bat --line-range :500 {}'"
    ];
    changeDirWidgetCommand = "${fdCommand} --type d";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -100'"
    ];
  };
}

