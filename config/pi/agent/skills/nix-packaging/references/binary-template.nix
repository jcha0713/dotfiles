# Pre-built Binary Template
# Copy to pkgs/<name>/default.nix and modify placeholders

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, zlib
}:

let
  inherit (stdenv.hostPlatform) system;

  # Define sources for each supported platform
  # Add/remove platforms as needed based on upstream releases
  sources = {
    x86_64-linux = {
      url = "https://github.com/OWNER/REPO/releases/download/vVERSION/PACKAGE-VERSION-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-PLACEHOLDER";  # Get with: nix-prefetch-url <url>
      sourceRoot = "PACKAGE-VERSION-x86_64-unknown-linux-gnu";
    };
    aarch64-darwin = {
      url = "https://github.com/OWNER/REPO/releases/download/vVERSION/PACKAGE-VERSION-aarch64-apple-darwin.tar.gz";
      hash = "sha256-PLACEHOLDER";
      sourceRoot = "PACKAGE-VERSION-aarch64-apple-darwin";
    };
    x86_64-darwin = {
      url = "https://github.com/OWNER/REPO/releases/download/vVERSION/PACKAGE-VERSION-x86_64-apple-darwin.tar.gz";
      hash = "sha256-PLACEHOLDER";
      sourceRoot = "PACKAGE-VERSION-x86_64-apple-darwin";
    };
  };

  # Look up source info for current system
  srcInfo = sources.${system} or (throw "Unsupported system: ${system}");

in
stdenv.mkDerivation rec {
  pname = "PACKAGE-NAME";
  version = "VERSION";

  src = fetchurl {
    url = srcInfo.url;
    hash = srcInfo.hash;
  };

  # Only needed on Linux to patch ELF binaries
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  # Libraries needed by the binary on Linux
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    stdenv.cc.cc.lib  # Provides libstdc++.so.6 and libgcc_s.so.1
  ];

  # Skip build/configure phases - we just need to install
  dontBuild = true;
  dontConfigure = true;

  # Set source root to match the directory inside the tarball
  sourceRoot = srcInfo.sourceRoot;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    
    # Copy the main binary (rename if needed)
    cp BINARY-NAME $out/bin/
    
    # Optional: create symlinks for alternative names
    ln -s $out/bin/BINARY-NAME $out/bin/ALTERNATIVE-NAME
    
    runHook postInstall
  '';

  meta = {
    description = "Brief description of the package";
    homepage = "https://github.com/OWNER/REPO";
    changelog = "https://github.com/OWNER/REPO/releases/tag/v${version}";
    license = lib.licenses.mit;  # Adjust as needed
    mainProgram = "BINARY-NAME";
    platforms = builtins.attrNames sources;
  };
}
