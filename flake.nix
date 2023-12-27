{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixos-unstable"; # Separate input for overriding
    myFlakes.url = "github:heywoodlh/flakes";
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-23.05";
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon/main";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    ssh-keys = {
      url = "https://github.com/heywoodlh.keys";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    osquery-fix-nixpkgs = {
      url = "github:nixos/nixpkgs/e4235192047a058776b3680f559579bf885881da";
    };
    #hyprland.url = "github:hyprwm/Hyprland/main";
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    spicetify.url = "github:heywoodlh/spicetify-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
  };

  outputs = inputs@{ self,
                      nixpkgs,
                      myFlakes,
                      nixpkgs-backports,
                      nixpkgs-lts,
                      nixos-apple-silicon,
                      nixos-wsl,
                      darwin,
                      home-manager,
                      jovian-nixos,
                      nur,
                      flake-utils,
                      spicetify,
                      nixos-hardware,
                      ssh-keys,
                      osquery-fix-nixpkgs,
                      flatpaks,
                      ... }:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    in {
    # macos targets
    packages.darwinConfigurations = {
      "nix-macbook-air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [
          ./darwin/hosts/m2-macbook-air.nix
          {
            environment.systemPackages = [
              myFlakes.packages.${system}.vim
            ];
          }
        ];
      };
      "nix-m1-mac-mini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [
          ./darwin/hosts/m1-mac-mini.nix
          {
            environment.systemPackages = [
              myFlakes.packages.${system}.vim
            ];
          }
        ];
      };
      # mac-mini output -- used with CI
      "nix-mac-mini" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = inputs;
        modules = [
          ./darwin/hosts/mac-mini.nix
        ];
      };
    };

    # nixos targets
    packages.nixosConfigurations = {
      nixos-macbook = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = inputs;
        modules = [
          ./nixos/hosts/macbook/configuration.nix
        ];
      };
      nixos-xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nixos-hardware.nixosModules.dell-xps-13-9310
          ./nixos/hosts/xps/configuration.nix
        ];
      };
      nix-steam-deck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/steam-deck/configuration.nix ];
      };
      nix-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-wsl/configuration.nix ];
      };
      nix-tools = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-tools/configuration.nix ];
      };
      nixos-arm64-vm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nixos-arm64-vm/configuration.nix ];
      };
      nix-precision = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-precision/configuration.nix ];
      };
      nixos-matrix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nixos-matrix/configuration.nix ];
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
      nix-drive = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-drive/configuration.nix ];
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
        modules = [
          ./nixos/hosts/generic-intel/configuration.nix
        ];
      };
      # Used in CI
      nixos-server-intel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/generic-intel-server/configuration.nix ];
      };
    };
    # home-manager targets (non NixOS/MacOS, ideally Arch Linux)
    packages.homeConfigurations = {
      # Used in CI
      heywoodlh = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          flatpaks.homeManagerModules.default
          ./roles/home-manager/linux.nix
          ./roles/home-manager/desktop.nix # Base desktop config
          ./roles/home-manager/linux/desktop.nix # Linux-specific desktop config
          ./roles/home-manager/linux/gnome-desktop.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
            fonts.fontconfig.enable = true;
            programs.home-manager.enable = true;
            targets.genericLinux.enable = true;
            home.packages = [
              pkgs.colima
              (pkgs.nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "JetBrainsMono" ]; })
              myFlakes.packages.${system}.git
              myFlakes.packages.${system}.vim
            ];
            home.file."bin/docker" = {
              enable = true;
              executable = true;
              text = ''
                #!/usr/bin/env bash
                ${pkgs.colima}/bin/colima list | grep default | grep -q Running || ${pkgs.colima}/bin/colima start default &>/dev/null # Start/create default colima instance if not running/created
                ${pkgs.docker-client}/bin/docker ''$@
              '';
            };
            home.file."bin/home-switch" = {
              enable = true;
              executable = true;
              text = ''
                #!/usr/bin/env bash
                git clone https://github.com/heywoodlh/nixos-configs ~/opt/nixos-configs &>/dev/null || true
                git -C ~/opt/nixos-configs pull origin master --rebase
                ## OS-specific support (mostly, Ubuntu vs anything else)
                ## Anything else will use nixpkgs-unstable
                EXTRA_ARGS=""
                if grep -iq Ubuntu /etc/os-release
                then
                  version="$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
                  ## Support for Ubuntu 22.04
                  if [[ "$version" == "22.04" ]]
                  then
                    EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-22.05"
                  fi
                  ## TODO: Support Ubuntu 24.04 when released
                fi
                nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage" --impure $EXTRA_ARGS
              '';
            };
          }
          #hyprland.homeManagerModules.default
          #./roles/home-manager/linux/hyprland.nix
        ];
        extraSpecialArgs = inputs;
      };
      heywoodlh-server = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./roles/home-manager/linux.nix
          ./roles/home-manager/linux/no-desktop.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
            home.packages = [
              myFlakes.packages.${system}.fish
              inputs.nixpkgs-backports.legacyPackages.${system}.docker-client
              myFlakes.packages.${system}.vim
            ];
            fonts.fontconfig.enable = true;
            targets.genericLinux.enable = true;
            programs.home-manager.enable = true;
          }
        ];
        extraSpecialArgs = inputs;
      };
    };
  });
}
