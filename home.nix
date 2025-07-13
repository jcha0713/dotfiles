{ config, pkgs, ... }:

let
  flexoki = pkgs.fetchFromGitHub {
    owner = "gosxrgxx";
    repo = "flexoki-light.yazi";
    rev = "main";
    sha256 = "sha256-5dlD4CvLwpSA2XJJtm562vAyZfsKWQGdbwkQJuXj5Jk=";
  };
  everforest = pkgs.fetchFromGitHub {
    owner = "Chromium-3-Oxide";
    repo = "everforest-medium.yazi";
    rev = "main";
    sha256 = "sha256-FXg++wVSGrJZnYodzkS4eVIeQE1xm8o0urnoInqfP5g=";
  };
in
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
    packages = with pkgs; [
      _1password-cli
      bat
      catimg
      colima
      comma
      curl
      darwin.trash
      deno
      fd
      fnm
      fx
      gh
      git-absorb
      nap
      nb
      ncurses
      pipx
      ripgrep
      rustup
      sqlite
      tailscale
      tree
      tree-sitter
      wakeonlan
      zk
      zsh-autosuggestions

      # TUI
      bottom
      circumflex
      w3m

      # GUI
      aldente
      discord
      espanso
      mos
      raycast
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
  };

  imports = [
    ./git.nix
  ];

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
    initExtra = # zsh
      ''
        eval "$(fnm env --use-on-cd --shell zsh)"

        source ${config.home.homeDirectory}/dotfiles/config/zsh/zk.zsh
        source ${config.home.homeDirectory}/dotfiles/config/zsh/functions.zsh

        # bind <C-n> to yazi(y)
        bindkey -s '^n' 'y\n'

        function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }

        function Resume {
          fg
          zle push-input
          BUFFER=""
          zle accept-line
        }
        zle -N Resume
        bindkey "^Z" Resume

        setopt PROMPT_SUBST
        RPROMPT='%(1j.⏸ %j.)'  # Shows job count when jobs exist

        # direnv (https://direnv.net/docs/hook.html)
        eval "$(direnv hook zsh)"
      '';
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.zoxide = {
    enable = true;
  };

  programs.fzf =
    let
      fdCommand = "fd --exclude '.git' --exclude 'node_modules' --exclude 'lua-language-server'";
    in
    {
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

  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        sort_dir_first = true;
        ratio = [
          1
          2
          5
        ];
      };
      preview = {
        wrap = "yes";
      };
    };
    theme = {
      flavor = {
        use = "kanso-zen";
      };
    };
  };

  programs.direnv.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };
    };
  };
}
