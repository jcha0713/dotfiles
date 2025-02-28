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

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, neovim-nix, ... }:
  let
    username = "jcha0713";
    # overlays = [
    #   inputs.neovim-nightly-overlay.overlays.default
    # ];

    configuration = { pkgs, ... }: {
      # nixpkgs.overlays = overlays;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [ 
        pkgs.home-manager
        # pkgs.neovim
        inputs.neovim-nix.packages.${pkgs.system}.bob
        pkgs.aerospace
        pkgs.docker
        pkgs.docker-compose

        # GUI apps
        # pkgs.discord
        # pkgs.aldente
        # pkgs._1password-gui
        # pkgs.mos
        # pkgs.raycast
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # https://github.com/LnL7/nix-darwin/issues/740
      nix.settings.extra-nix-path = "nixpkgs=flake:nixpkgs";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      nixpkgs.config.allowUnfree = true;

      # https://discourse.nixos.org/t/zsh-compinit-warning-on-every-shell-session/22735/6
      programs.zsh.enableCompletion = false;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#jcha_16
    darwinConfigurations."jcha_16" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration

        # Home Manager module
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."jcha_16".pkgs;
  };
}
