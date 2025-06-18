{ fetchurl }:
(oldAttrs: {
  version = "1.2.16";
  src = fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v1.2.16/bun-darwin-aarch64.zip";
    sha256 = "sha256:20168217330b0ebb8e914836e63aaf57140aff0cf957162276587cab0412f17f";
  };
})
