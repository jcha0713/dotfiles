{
  description = "Unified NixOS + Darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For ThinkPad (NixOS)
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For Mac Mini (Darwin)
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      # Shared special args
      sharedSpecialArgs = { inherit inputs; };
    in
    {
      # NixOS configurations
      nixosConfigurations.think = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = sharedSpecialArgs;
        modules = [
          ./hosts/think
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.joohoon = ./home/nixos.nix;
            home-manager.extraSpecialArgs = {
              dotfilesPath = "/home/joohoon/dotfiles";
            };
          }
        ];
      };

      # Darwin configurations
      darwinConfigurations.mini = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = sharedSpecialArgs // { username = "jcha0713"; system = "aarch64-darwin"; };
        modules = [
          ./hosts/mini
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jcha0713 = ./home/darwin.nix;
            home-manager.extraSpecialArgs = {
              dotfilesPath = "/Users/jcha0713/dotfiles";
            };
          }
        ];
      };
    };
}
