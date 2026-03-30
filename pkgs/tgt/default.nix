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
  cargoHash = "sha256-p3NcT0dBvtPUav4Xjwus1cEKWumqmpvmyr+vvJ3iHbU=";

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
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "tgt";
    platforms = lib.platforms.unix;
  };
}
