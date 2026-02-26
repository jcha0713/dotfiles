# Go Build from Source Template
# Copy to pkgs/<name>/default.nix and modify placeholders

{ lib
, buildGoModule
, fetchFromGitHub
, stdenv
}:

buildGoModule rec {
  pname = "PACKAGE-NAME";
  version = "VERSION";

  src = fetchFromGitHub {
    owner = "GITHUB-OWNER";
    repo = "REPO-NAME";
    rev = "v${version}";  # or "${version}" if no v prefix
    hash = "sha256-PLACEHOLDER";
  };

  # For Go modules - first build with lib.fakeHash, then use the "got:" hash
  vendorHash = "sha256-PLACEHOLDER";

  # Optional: specify which sub-packages to build
  # subPackages = [ "cmd/binary-name" ];

  # Optional: ldflags for version info
  # ldflags = [
  #   "-s" "-w"
  #   "-X main.version=${version}"
  # ];

  # Skip tests if needed
  doCheck = false;

  meta = {
    description = "Brief description of the package";
    homepage = "https://github.com/OWNER/REPO";
    license = lib.licenses.mit;  # Adjust as needed
    mainProgram = "BINARY-NAME";
  };
}
