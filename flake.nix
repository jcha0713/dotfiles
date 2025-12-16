{
  description = "jcha0713 Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nix.url = "github:tirimia/neovim-nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      neovim-nix,
      ...
    }:
    let
      username = "jcha0713";

      overlays = [
        (import ./overlays)
        # include external overlays
        # inputs.neovim-nightly-overlay.overlays.default
      ];

      createDarwinSystem =
        { system, hostname }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs username system; };
          modules = [
            (
              { pkgs, system, ... }:
              {
                users = {
                  users.${username} = {
                    home = "/Users/${username}";
                    name = "${username}";
                  };
                };
                nixpkgs.overlays = overlays;

                # List packages installed in system profile. To search by name, run:
                # $ nix-env -qaP | grep wget
                environment.systemPackages = [
                  pkgs.home-manager
                  pkgs.nixfmt-rfc-style
                  pkgs.neovim
                  # FIXME: bob from neovim-nix fails with apple_sdk_11_0 error
                  # inputs.neovim-nix.packages.${pkgs.system}.bob
                  pkgs.aerospace
                  pkgs.docker
                  pkgs.docker-compose
                  pkgs.wezterm
                ];

                # Necessary for using flakes on this system.
                nix.settings.experimental-features = "nix-command flakes";

                # https://github.com/LnL7/nix-darwin/issues/740
                nix.settings.extra-nix-path = "nixpkgs=flake:nixpkgs";

                # Create /etc/zshrc that loads the nix-darwin environment.
                programs.zsh.enable = true; # default shell on catalina
                # programs.fish.enable = true;

                # Set Git commit hash for darwin-version.
                system.configurationRevision = self.rev or self.dirtyRev or null;

                # Used for backwards compatibility, please read the changelog before changing.
                # $ darwin-rebuild changelog
                system.stateVersion = 5;

                # The platform the configuration will be used on.
                nixpkgs.hostPlatform = system;

                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (pkgs.lib.getName pkg) [
                    "aldente"
                    "mos"
                    "raycast"
                    "discord"
                    "1password-cli"
                  ];
              }
            )

            # Home Manager module
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./home.nix;
              home-manager.extraSpecialArgs = { inherit system; };
            }
          ];
        };
    in
    {
      darwinConfigurations."jcha_16" = createDarwinSystem {
        system = "x86_64-darwin";
        hostname = "jcha_16";
      };

      darwinConfigurations."jcha_mini" = createDarwinSystem {
        system = "aarch64-darwin";
        hostname = "jcha_mini";
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."jcha_16".pkgs;
    };
}
