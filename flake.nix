{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, darwin, ... }:
  let 
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
  in {
    # nix-macbook-air target 
    darwinConfigurations = {
      "nix-macbook-air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./darwin/nix-macbook-air.nix ];
      };
    };

    # nixos target
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./workstation/desktop.nix ];
      };
    };
  };
}
