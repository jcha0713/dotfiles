{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  dbus,
}:

stdenv.mkDerivation rec {
  pname = "gitbutler-cli";
  version = "0.19.5-2897";

  src = fetchurl {
    url = "https://releases.gitbutler.com/releases/release/${version}/linux/x86_64/but";
    hash = "sha256-qQAjL6ImIvCKGXELWmcAMBs0J3QPNP+0UsXUElpO1eg=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    dbus
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/but
    chmod +x $out/bin/but
    runHook postInstall
  '';

  meta = {
    description = "GitButler CLI (but)";
    homepage = "https://gitbutler.com";
    changelog = "https://github.com/gitbutlerapp/gitbutler/releases";
    license = lib.licenses.unfree;
    mainProgram = "but";
    platforms = [ "x86_64-linux" ];
  };
}
