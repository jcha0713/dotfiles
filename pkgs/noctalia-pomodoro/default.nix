{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "noctalia-pomodoro";
  version = "unstable-2025-02-28";

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-plugins";
    rev = "main";
    hash = "sha256-6OoIZo04+cQAR/XtaAKOVOHVpaImJ1EhJfuF1o8xdrU=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/noctalia/plugins
    cp -r $src/pomodoro $out/share/noctalia/plugins/
    runHook postInstall
  '';

  meta = {
    description = "A Pomodoro timer plugin for Noctalia for productivity";
    homepage = "https://github.com/noctalia-dev/noctalia-plugins/tree/main/pomodoro";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
