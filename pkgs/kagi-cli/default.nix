{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.9.0";
  target =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "x86_64-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "aarch64-darwin" then
      "aarch64-apple-darwin"
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      "x86_64-apple-darwin"
    else
      throw "kagi-cli: unsupported system ${stdenv.hostPlatform.system}";

  hashes = {
    x86_64-unknown-linux-gnu = "sha256-jIt96TVUeanbOLWUbUAuaBYRlu0YKvCq0uf7KodY1bI=";
    aarch64-apple-darwin = "sha256-cAB2bji3q8L7jMKeGLSWtzZaFhB6MgwNN+/fiAappO0=";
    x86_64-apple-darwin = "sha256-3s34vR0W3MdCgrHVbX72Lc62Ro4danOVwrZ6H4j6OCQ=";
  };
in
stdenv.mkDerivation {
  pname = "kagi-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Microck/kagi-cli/releases/download/v${version}/kagi-v${version}-${target}";
    hash = hashes.${target};
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/kagi"
    runHook postInstall
  '';

  meta = {
    description = "Terminal CLI for Kagi search, public feeds, and subscriber features";
    homepage = "https://github.com/Microck/kagi-cli";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "kagi";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
