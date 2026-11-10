# kime-wayland is built with dlopen-based wayland-client but the NixOS
# package doesn't wrap it with libwayland, so it crashes on start with
# "NoWaylandLib". This makes native Wayland apps (Firefox, Chromium,
# Electron, etc.) fall back to no input method.
{ makeWrapper, wayland }:
(oldAttrs: {
  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
  postFixup = (oldAttrs.postFixup or "") + ''
    wrapProgram $out/bin/kime-wayland --prefix LD_LIBRARY_PATH : ${wayland}/lib
  '';
})
