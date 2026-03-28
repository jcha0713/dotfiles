{
  pkgs,
  ...
}:
let
  languageServers = with pkgs; [
    nixd
    lua-language-server
    typescript-language-server
  ];

  formatters = with pkgs; [
    oxfmt
    nixfmt
  ];
in
{
  home.packages = languageServers ++ formatters;
}
