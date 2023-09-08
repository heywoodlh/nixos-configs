{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-23.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    vim-configs.url = "github:heywoodlh/flakes/main?dir=vim";
    git-configs.url = "github:heywoodlh/flakes/main?dir=git";
    wezterm-configs.url = "github:heywoodlh/flakes/main?dir=wezterm";
    fish-configs.url = "github:heywoodlh/flakes/main?dir=fish";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/main";
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    spicetify.url = "gitlab:kylesferrazza/spicetify-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self,
                      nixpkgs,
                      nixpkgs-unstable,
                      nixpkgs-backports,
                      nixos-wsl,
                      vim-configs,
                      git-configs,
                      wezterm-configs,
                      fish-configs,
                      darwin,
                      home-manager,
                      hyprland,
                      jovian-nixos,
                      nur,
                      flake-utils,
                      spicetify,
                      nixos-hardware,
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
              vim-configs.defaultPackage.${system}
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
              vim-configs.defaultPackage.${system}
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
      nix-yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./nixos/hosts/yoga/configuration.nix
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
            programs.tmux.shell = "/home/heywoodlh/.nix-profile/bin/fish";
            targets.genericLinux.enable = true;
            home.packages = [
              pkgs.colima
              inputs.nixpkgs-backports.legacyPackages.${system}.docker-client
              fish-configs.packages.${system}.fish
              (pkgs.nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "JetBrainsMono" ]; })
              vim-configs.defaultPackage.${system}
              git-configs.packages.${system}.git
            ];
            home.file."bin/docker" = {
              enable = true;
              executable = true;
              text = ''
                #!/usr/bin/env bash
                ${pkgs.colima}/bin/colima list | grep default | grep -q Running || ${pkgs.colima}/bin/colima start default # Start/create default colima instance if not running/created
                ${pkgs.docker-client}/bin/docker ''$@
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
              fish-configs.packages.${system}.fish
              inputs.nixpkgs-backports.legacyPackages.${system}.docker-client
              vim-configs.defaultPackage.${system}
            ];
            fonts.fontconfig.enable = true;
            targets.genericLinux.enable = true;
            programs.home-manager.enable = true;
            programs.zsh = {
              shellAliases = {
                # Override the home-switch function provided in roles/home-manager/linux.nix
                home-switch = "git -C ~/opt/nixos-configs pull origin master; nix --extra-experimental-features 'nix-command flakes' run ~/opt/nixos-configs#homeConfigurations.heywoodlh-server.activationPackage --impure";
              };
              initExtra = ''
                PROMPT=$'%~ %F{green}$(git branch --show-current 2&>/dev/null) %F{red}$(env | grep -i SSH_CLIENT | grep -v "0.0.0.0" | cut -d= -f2 | awk \'{print $1}\' 2&>/dev/null) %F{white}\n> '
              '';
            };
          }
        ];
        extraSpecialArgs = inputs;
      };
    };
  });
}
