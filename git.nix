let
  deltaThemes = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dandavison/delta/main/themes.gitconfig";
    sha256 = "sha256:1pkqd36ls3cc6xgycd6sawpnwvgbchs54dkgg007algkhqxv7wch";
  };
in
{
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

        # difftastic
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

      # SSH URL rewriting
      url."git@github.com:" = {
        insteadOf = "https://github.com/";
      };
      url."git@gitlab.com:" = {
        insteadOf = "https://gitlab.com/";
      };
      url."git@bitbucket.org:" = {
        insteadOf = "https://bitbucket.org/";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "arctic-fox";
      line-numbers = true;
      hyperlinks = true;
      # side-by-side = true;
    };
  };
}
