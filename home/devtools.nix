{
  pkgs,
  ...
}:
let
  languageServers = with pkgs; [
    nixd
    lua-language-server
    typescript-language-server
    vscode-langservers-extracted
  ];

  formatters = with pkgs; [
    oxfmt
    nixfmt
    stylua
  ];

  linters = with pkgs; [
    oxlint
    eslint_d
  ];

  runtimes = with pkgs; [
    bun
  ];

  misc = with pkgs; [
    tree-sitter
    rustup
    sqlite
  ];
in
{
  home.packages = languageServers ++ formatters ++ linters ++ runtimes ++ misc;
}
