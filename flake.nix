{
  description = "Unified NixOS + Darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For ThinkPad (NixOS)
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For Mac Mini (Darwin)
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Worktrunk - CLI for git worktree management
    worktrunk = {
      url = "github:max-sixty/worktrunk";
    };

    # tgt - Telegram TUI
    tgt = {
      url = "github:FedericoBruzzone/tgt";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
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
              inherit inputs;
              dotfilesPath = "/home/joohoon/dotfiles";
            };
          }
        ];
      };

      # Darwin configurations
      darwinConfigurations.mini = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = sharedSpecialArgs // {
          username = "jcha0713";
          system = "aarch64-darwin";
        };
        modules = [
          ./hosts/mini
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.jcha0713 = ./home/darwin.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              dotfilesPath = "/Users/jcha0713/dotfiles";
            };
          }
        ];
      };
    };
}
