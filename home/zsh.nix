{ config, pkgs, ... }:

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

        # Ensure fzf key bindings work with vi-mode
        # Bind Ctrl+R to fzf history search (works in both insert and normal mode)
        bindkey '^R' fzf-history-widget
        bindkey -M vicmd '^R' fzf-history-widget
      '';
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "fzf-zsh";
        src = pkgs.fzf;
        file = "share/fzf/completion.zsh";
      }
      {
        name = "fzf-zsh-keybindings";
        src = pkgs.fzf;
        file = "share/fzf/key-bindings.zsh";
      }
    ];
  };

  programs.direnv.enable = true;
}
