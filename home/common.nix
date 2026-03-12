{
  config,
  pkgs,
  lib,
  dotfilesPath,
  inputs,
  ...
}:

let
  deltaThemes = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dandavison/delta/main/themes.gitconfig";
    sha256 = "sha256:1pkqd36ls3cc6xgycd6sawpnwvgbchs54dkgg007algkhqxv7wch";
  };

  octorus = pkgs.callPackage ../pkgs/octorus/default.nix { };

  yaz = pkgs.writeShellScriptBin "yaz" ''
    exec ${pkgs.yazi}/bin/ya "$@"
  '';

  ya = lib.hiPrio (
    pkgs.writeShellScriptBin "ya" ''
      exec ${dotfilesPath}/bin/ya "$@"
    ''
  );
in
{
  # Git configuration
  programs.git = {
    enable = true;
    ignores = [
      ".envrc"
      ".direnv"
    ];
    settings = {
      user = {
        name = "jcha0713";
        email = "joocha0713@gmail.com";
      };
      alias = {
        undo = "reset HEAD~1 --mixed";
        st = "status -s";
        l = "log --oneline --graph --all";
        dlog = "-c diff.external=difft log --ext-diff";
        dshow = "-c diff.external=difft show --ext-diff";
        ddiff = "-c diff.external=difft diff";
        dside = "-c delta.features='arctic-fox side-by-side' diff";
      };
      include = {
        path = deltaThemes;
      };
      status.showUntrackedFiles = "all";
      init.defaultBranch = "main";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      push = {
        followTags = true;
      };
      fetch = {
        prune = true;
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
      pull.rebase = true;
      url."git@github.com:".insteadOf = "https://github.com/";
      url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
      url."git@bitbucket.org:".insteadOf = "https://bitbucket.org/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "arctic-fox";
      line-numbers = true;
      hyperlinks = true;
    };
  };

  home.file = {
    # pi
    ".pi/agent/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/keybindings.json";
    ".pi/agent/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/settings.json";
    ".pi/agent/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/skills";
    ".pi/agent/prompts".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/prompts";
    ".pi/agent/extensions".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/extensions";
  };

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";
    };

    wezterm = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/wezterm";
    };

    ghostty = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty";
    };

    zellij = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zellij";
    };

    sprinkles = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/sprinkles";
    };

    opencode = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/opencode";
    };

    worktrunk = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/worktrunk";
    };

    "yazi/flavors/kanso-zen.yazi" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/yazi/flavors/kanso-zen.yazi";
    };

  };

  xdg.desktopEntries.nvim-ghostty = {
    name = "Neovim (Ghostty)";
    genericName = "Text Editor";
    comment = "Edit text files in Neovim via Ghostty";
    exec = "ghostty -e nvim %F";
    terminal = false;
    categories = [
      "Utility"
      "TextEditor"
    ];
    mimeType = [ "text/plain" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "nvim-ghostty.desktop" ];
    };
  };

  home.sessionPath = [
    "${dotfilesPath}/bin"
  ];

  # Common CLI tools (used by both NixOS and Darwin)
  home.packages = with pkgs; [
    zsh
    ripgrep
    bat
    fd
    lazygit
    tree-sitter
    tree
    gh
    curl
    ncurses
    zellij
    go
    rustup
    nixfmt
    jq
    octorus
    just
    yaz
    ya
    inputs.worktrunk.packages.${pkgs.system}.default
    bob-nvim
  ];

  # Directory jumper
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # TUI git client
  programs.lazygit = {
    enable = true;
  };

  # TUI file manager
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
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
}
