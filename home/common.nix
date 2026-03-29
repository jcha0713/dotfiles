{
  config,
  pkgs,
  lib,
  dotfilesPath,
  inputs,
  ...
}:

let
  octorus = pkgs.callPackage ../pkgs/octorus/default.nix { };
  gitbutlerCli = pkgs.callPackage ../pkgs/gitbutler-cli { };
  tgt = pkgs.callPackage ../pkgs/tgt/default.nix { inherit inputs; };

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
  imports = [
    ./git.nix
    ./devtools.nix
  ];

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
    neuvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/neuvim";
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

    "yazi/flavors" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/yazi/flavors";
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

  home.sessionVariables = {
    NVIM_APPNAME = "neuvim";
  };

  # Common CLI tools (used by both NixOS and Darwin)
  home.packages =
    (with pkgs; [
      zsh
      ripgrep
      bat
      fd
      lazygit
      tree
      gh
      curl
      ncurses
      zellij
      go
      jq
      octorus
      just
      yaz
      ya
      inputs.worktrunk.packages.${pkgs.system}.default
      tgt
      bob-nvim
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      gitbutlerCli
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
        dark = "vague";
      };
    };
  };
}
