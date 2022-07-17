vim.g.rooter_patterns = {
  "!.git/worktrees", -- without this line, git commit in neogit does not work well because vim-rooter is changing the cwd
  ".git",
}

vim.g.rooter_change_directory_for_non_project_files = "current"
