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
    nur.url = "github:nix-community/NUR";
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, jovian-nixos, nur, nix-on-droid, ... }: 
    let
      nixpkgsDefaults = {
        config = {
          allowUnfree = true;
        };
      }; 
    in rec {
    # macos targets
    darwinConfigurations = {
      "nix-macbook-air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [ ./darwin/hosts/m2-macbook-air.nix ];
      };
      "hephaestus" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [ ./darwin/hosts/hephaestus.nix ];
      };
      # mac-mini output -- used with CI
      "nix-mac-mini" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = inputs;
        modules = [ ./darwin/hosts/mac-mini.nix ];
      };
    };

    # nixos targets
    nixosConfigurations = {
      nix-pomerium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-pomerium/configuration.nix ];
      };
      flipperbeet-chromebook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/flipperbeet-chromebook/configuration.nix ];
      };
      nix-steam-deck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/steam-deck/configuration.nix ];
      };
      nix-thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/thinkpad-x1/configuration.nix ];
      };
      nix-razer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/razer-blade-15/configuration.nix ];
      };
      nix-tools = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-tools/configuration.nix ];
      };
      nix-kube = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-kube/configuration.nix ];
      };
      nix-precision = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-precision/configuration.nix ];
      };
      nix-nvidia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-nvidia/configuration.nix ];
      };
      nix-ext-net = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-ext-net/configuration.nix ];
      };
      nix-media = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-media/configuration.nix ];
      };
      nix-backups = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-backups/configuration.nix ];
      };
      # Used in CI
      nixos-desktop-intel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/generic-intel/configuration.nix ];
      };
      # Used in CI
      nixos-server-intel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/generic-intel-server/configuration.nix ];
      };
    };
    # home-manager targets (non NixOS/MacOS, ideally Arch Linux) 
    homeConfigurations = {
      # Used in CI
      heywoodlh-desktop-x86_64 = home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs (nixpkgsDefaults // { system = "x86_64-linux"; });
        #pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./roles/home-manager/linux.nix
          ./roles/home-manager/non-nixos/base.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
            fonts.fontconfig.enable = true;
          }
        ];
        extraSpecialArgs = inputs;
      };
      heywoodlh-desktop-aarch64 = home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs (nixpkgsDefaults // { system = "aarch64-linux"; });
        #pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./roles/home-manager/linux.nix
          ./roles/home-manager/non-nixos/base.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
            fonts.fontconfig.enable = true;
          }
        ];
        extraSpecialArgs = inputs;
      };
      heywoodlh-server-x86_64 = home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs (nixpkgsDefaults // { system = "x86_64-linux"; });
        #pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./roles/home-manager/linux.nix
          ./roles/home-manager/non-nixos/no-desktop.nix
          ./roles/home-manager/non-nixos/base.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
            fonts.fontconfig.enable = true;
            programs.zsh.shellAliases = {
              # Override the home-switch function provided in roles/home-manager/linux.nix
              home-switch = "git -C ~/opt/nixos-configs pull origin master; nix run ~/opt/nixos-configs#homeConfigurations.heywoodlh-server-$(arch).activationPackage --impure";
            };
          }
        ];
        extraSpecialArgs = inputs;
      };
      heywoodlh-server-aarch64 = home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs (nixpkgsDefaults // { system = "aarch64-linux"; });
        #pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./roles/home-manager/linux.nix
          ./roles/home-manager/non-nixos/no-desktop.nix
          ./roles/home-manager/non-nixos/base.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
            fonts.fontconfig.enable = true;
            programs.zsh.shellAliases = {
              # Override the home-switch function provided in roles/home-manager/linux.nix
              home-switch = "git -C ~/opt/nixos-configs pull origin master; nix run ~/opt/nixos-configs#homeConfigurations.heywoodlh-server-$(arch).activationPackage --impure";
            };
          }
        ];
        extraSpecialArgs = inputs;
      };
    };

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = inputs;
      modules = [ ./nixos/droid.nix ];
    };
  };
}
