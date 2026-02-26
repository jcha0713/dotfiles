# Rust Build from Source Template
# Copy to pkgs/<name>/default.nix and modify placeholders

{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, stdenv
, darwin
, # Add other dependencies as needed
  openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "PACKAGE-NAME";
  version = "VERSION";

  src = fetchFromGitHub {
    owner = "GITHUB-OWNER";
    repo = "REPO-NAME";
    rev = "v${version}";  # or "${version}" if no v prefix
    hash = "sha256-PLACEHOLDER";
    # Use lib.fakeHash first, then replace with "got:" hash from error
  };

  # This hash is for the vendored Cargo dependencies
  # First build with lib.fakeHash, then use the "got:" hash
  cargoHash = "sha256-PLACEHOLDER";

  nativeBuildInputs = [
    pkg-config
    # Add other build tools here
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
    # Add other Darwin frameworks as needed
  ];

  # Skip tests if they fail due to environment differences
  # (common for TUI apps with snapshot tests)
  doCheck = false;

  # Optional: post-install steps
  postInstall = ''
    # Example: rename binary or create symlinks
    # ln -s $out/bin/or $out/bin/octorus
  '';

  meta = {
    description = "Brief description of the package";
    homepage = "https://github.com/OWNER/REPO";
    changelog = "https://github.com/OWNER/REPO/releases/tag/v${version}";
    license = lib.licenses.mit;  # Adjust as needed
    maintainers = [];  # Add yourself if maintaining
    mainProgram = "BINARY-NAME";
  };
}
