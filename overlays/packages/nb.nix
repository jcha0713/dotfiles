{ fetchFromGitHub }:
(oldAttrs: {
  version = "7.17.0";
  src = fetchFromGitHub {
    owner = "xwmx";
    repo = "nb";
    rev = "7.17.0";
    sha256 = "sha256-gUI7hAZabYPHkSwGtFZxEoi5Hw76fOLYbMZQIvsnSas=";
  };
})
