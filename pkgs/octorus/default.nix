{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, zlib
}:

let
  inherit (stdenv.hostPlatform) system;

  # Platform-specific source info
  sources = {
    x86_64-linux = {
      url = "https://github.com/ushironoko/octorus/releases/download/v0.5.1/octorus-0.5.1-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-oORILkvF9poVHb0Jhi1vSoOfWLYFnZhjnzuDmF35oBs=";
      sourceRoot = "octorus-0.5.1-x86_64-unknown-linux-gnu";
    };
    aarch64-darwin = {
      url = "https://github.com/ushironoko/octorus/releases/download/v0.5.1/octorus-0.5.1-aarch64-apple-darwin.tar.gz";
      hash = "sha256-HMJhCd/JLWYp8q2cHhQPE9B7jSA3WDGfnyoU46THTJQ=";
      sourceRoot = "octorus-0.5.1-aarch64-apple-darwin";
    };
    x86_64-darwin = {
      url = "https://github.com/ushironoko/octorus/releases/download/v0.5.1/octorus-0.5.1-x86_64-apple-darwin.tar.gz";
      hash = "sha256-FWIn7lJ5nnBVffg4D6lc+Su/RjwGd2G9Y8iL6gObxxE=";
      sourceRoot = "octorus-0.5.1-x86_64-apple-darwin";
    };
  };

  srcInfo = sources.${system} or (throw "Unsupported system: ${system}");

in
stdenv.mkDerivation rec {
  pname = "octorus";
  version = "0.5.1";

  src = fetchurl {
    url = srcInfo.url;
    hash = srcInfo.hash;
  };

  # Only use autoPatchelfHook on Linux (Darwin doesn't need it)
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    stdenv.cc.cc.lib
  ];

  dontBuild = true;
  dontConfigure = true;

  sourceRoot = srcInfo.sourceRoot;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp or $out/bin/
    ln -s $out/bin/or $out/bin/octorus
    runHook postInstall
  '';

  meta = {
    description = "TUI PR review tool for GitHub, designed for Helix editor users";
    homepage = "https://github.com/ushironoko/octorus";
    changelog = "https://github.com/ushironoko/octorus/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "or";
    platforms = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
  };
}
