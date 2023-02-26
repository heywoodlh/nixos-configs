{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }: {
    darwinConfigurations = {
      # nix-macbook-air target 
      "nix-macbook-air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./darwin/nix-macbook-air.nix ];
      };
      # chg-macbook-pro for CI
      "nix-mac-chg" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [ ./darwin/chg-macbook-pro.nix ];
      };
      # generic darwin intel config
      "macos-desktop-intel" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [ ./darwin/desktop.nix ];
      };
      # generic darwin m1/m2 config
      "macos-desktop-m1" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./darwin/desktop.nix ];
      };
    };

    # nixos target
    nixosConfigurations = {
      nix-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-vm/vm.nix ];
      };
      nixos-desktop-intel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/generic-intel/generic.nix ];
      };
    };
  };
}
