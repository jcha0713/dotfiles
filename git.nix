{
  programs.git = {
    enable = true;
    userName = "jcha0713";
    userEmail = "joocha0713@gmail.com";
    aliases = {
      undo = "reset HEAD~1 --mixed";
      st = "status -s";
      l = "log --oneline --graph --all";
    };
    ignores = [
      ".envrc"
      ".direnv"
    ];
    extraConfig = {
      status.showUntrackedFiles = "all";
      init.defaultBranch = "main";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
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
    };
    delta = {
      enable = true;
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "decorations";
        whitespace-error-style = "22 reverse";
      };

    };
  };
}
