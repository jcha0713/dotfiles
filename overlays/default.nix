final: prev: {
  nb = prev.nb.overrideAttrs (
    import ./packages/nb.nix {
      inherit (prev) fetchFromGitHub;
    }
  );

  kime = prev.kime.overrideAttrs (
    import ./packages/kime.nix {
      inherit (prev) makeWrapper wayland;
    }
  );
}
