{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "noctalia-sticky-notes";
  version = "unstable-2026-03-03";

  src = fetchFromGitHub {
    owner = "jcha0713";
    repo = "noctalia-plugins";
    rev = "dfa0af032315f9cf4e43b90385e5faec2a5eea34";
    hash = "sha256-UAVpBqsfHgYKSrORDIykjUDuRgtvYVmNpfmGZ/+dy0k=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/noctalia/plugins
    cp -r $src/sticky-notes $out/share/noctalia/plugins/
    runHook postInstall
  '';

  meta = {
    description = "A sticky notes plugin for Noctalia Shell";
    homepage = "https://github.com/jcha0713/noctalia-plugins/tree/main/sticky-notes";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
