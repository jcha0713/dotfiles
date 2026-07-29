{
  lib,
  rustPlatform,
  inputs,
}:

let
  src = inputs.kagi;
  cargoToml = builtins.fromTOML (builtins.readFile "${src}/Cargo.toml");
in
rustPlatform.buildRustPackage {
  pname = "kagi-cli";
  version = cargoToml.package.version;

  inherit src;

  # Use upstream's checked-in lockfile from the flake input, like pkgs/tgt.
  cargoLock.lockFile = "${src}/Cargo.lock";

  # Integration tests can require network/API/auth state.
  doCheck = false;

  meta = {
    description = "Agent-native CLI for Kagi subscribers with JSON-first search output";
    homepage = "https://github.com/Microck/kagi-cli";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "kagi";
    platforms = lib.platforms.unix;
  };
}
