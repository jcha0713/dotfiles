{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "noctalia-sticky-notes";
  version = "unstable-2025-02-28";

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-plugins";
    rev = "main";
    hash = "sha256-S7YwPeum7mk0OCG8lpR+vV4m7dmTFnmwgsI/aJCk9xo=";
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
    homepage = "https://github.com/noctalia-dev/noctalia-plugins/tree/main/sticky-notes";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
