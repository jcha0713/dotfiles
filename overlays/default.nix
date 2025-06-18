self: super: {
  bun = super.bun.overrideAttrs (
    import ./packages/bun.nix {
      inherit (super) fetchurl;
    }
  );

  nb = super.nb.overrideAttrs (
    import ./packages/nb.nix {
      inherit (super) fetchFromGitHub;
    }
  );
}
