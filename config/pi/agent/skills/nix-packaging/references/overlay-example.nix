# Overlay Example: Override an existing nixpkgs package
# Place in overlays/default.nix or add to your flake's nixpkgs.overlays

self: super: {
  # Override an existing package with a newer version
  package-name = super.package-name.overrideAttrs (oldAttrs: {
    version = "NEW-VERSION";
    src = super.fetchFromGitHub {
      owner = "GITHUB-OWNER";
      repo = "REPO-NAME";
      rev = "vNEW-VERSION";  # Tag or commit hash
      hash = "sha256-PLACEHOLDER";
    };
    
    # For Rust/Go packages, also update vendor hash
    # cargoHash = "sha256-PLACEHOLDER";
    # vendorHash = "sha256-PLACEHOLDER";
  });
}

# Alternative: Define as a separate file in overlays/packages/
# { fetchFromGitHub }:
# (oldAttrs: {
#   version = "NEW-VERSION";
#   src = fetchFromGitHub { ... };
# })

# Then import in overlays/default.nix:
# package-name = super.package-name.overrideAttrs (
#   import ./packages/package-name.nix {
#     inherit (super) fetchFromGitHub;
#   })
