{ config, pkgs, ... }:

let
  fdCommand = "fd --exclude '.git' --exclude 'node_modules' --exclude 'lua-language-server'";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = import ../config/zsh/aliases.nix;
    oh-my-zsh = {
      enable = true;
      theme = "kolo";
    };
    initContent = # zsh
      ''
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

        # Fix: Ensure fzf-history-widget is bound to Ctrl+R
        # This runs once after zsh-vi-mode initializes
        __fzf_ctrl_r_fix() {
          bindkey '^R' fzf-history-widget
          bindkey -M viins '^R' fzf-history-widget
          bindkey -M vicmd '^R' fzf-history-widget
          # Remove from precmd so it only runs once
          precmd_functions=(${precmd_functions:#__fzf_ctrl_r_fix})
        }
        precmd_functions+=(__fzf_ctrl_r_fix)
      '';
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.direnv.enable = true;

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
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
