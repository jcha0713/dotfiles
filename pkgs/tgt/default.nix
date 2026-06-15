{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  tdlib,
  stdenv,
  apple-sdk ? null,
  inputs,
}:

rustPlatform.buildRustPackage rec {
  pname = "tgt";
  version = "unstable-${inputs.tgt.shortRev or (builtins.substring 0 7 inputs.tgt.rev)}";

  src = inputs.tgt;
  # Use importCargoLock instead of fetchCargoVendor. crates.io currently blocks the
  # python-requests User-Agent used by fetch-cargo-vendor-util with HTTP 403.
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk ];

  buildInputs = [
    openssl
    tdlib
  ];

  doCheck = false;

  buildNoDefaultFeatures = true;
  buildFeatures = [ "pkg-config" ];

  preBuild = ''
    export HOME="$TMPDIR"
    export XDG_CONFIG_HOME="$TMPDIR/.config"
    export XDG_DATA_HOME="$TMPDIR/.local/share"
  '';

  env = {
    RUSTFLAGS = "-C link-arg=-Wl,-rpath,${tdlib}/lib -L ${openssl}/lib";
    LOCAL_TDLIB_PATH = "${tdlib}/lib";
  };

  meta = {
    description = "TUI for Telegram written in Rust";
    homepage = "https://github.com/FedericoBruzzone/tgt";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "tgt";
    platforms = lib.platforms.unix;
  };
}
