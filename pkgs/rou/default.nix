{
  lib,
  buildGoModule,
}:

buildGoModule rec {
  pname = "rou";
  version = "0.1.0";

  src = lib.cleanSource ./.;
  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Minimal CLI for choosing a programming language";
    license = lib.licenses.mit;
    mainProgram = "rou";
    platforms = lib.platforms.unix;
  };
}
