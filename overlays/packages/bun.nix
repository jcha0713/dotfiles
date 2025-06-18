{ fetchurl, stdenv }:
let
  system = stdenv.hostPlatform.system;
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.2.16/bun-darwin-aarch64.zip";
      sha256 = "sha256:20168217330b0ebb8e914836e63aaf57140aff0cf957162276587cab0412f17f";
    };
    "x86_64-darwin" = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.2.16/bun-darwin-x64.zip";
      sha256 = "sha256:93b26e67d1f219a2ab80867bd130db1f5d109170b38cc70f41925d4198c11753";
    };
  };
in
(oldAttrs: {
  version = "1.2.16";
  src = fetchurl (sources.${system});
})
