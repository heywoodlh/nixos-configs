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
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, jovian-nixos, ... }: {
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
        modules = [ ./nixos/hosts/nix-vm/configuration.nix ];
      };
      nix-vostro = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-vostro/configuration.nix ];
      };
      nix-steam-deck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/steam-deck/configuration.nix ];
      };
      nix-razer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/razer-blade-15/configuration.nix ];
      };
      nix-xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/xps-13/configuration.nix ];
      };
      nix-tools = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-tools/configuration.nix ];
      };
      nix-kube-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-kube-1/configuration.nix ];
      };
      nix-kube-2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-kube-2/configuration.nix ];
      };
      nix-kube-3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-kube-3/configuration.nix ];
      };
      nixos-desktop-intel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/generic-intel/configuration.nix ];
      };
      nixos-server-intel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/generic-intel-server/configuration.nix ];
      };
    };
  };
}