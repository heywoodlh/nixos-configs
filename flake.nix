{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, darwin, home-manager, jovian-nixos, nur, flake-utils, ... }:
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
        modules = [ ./darwin/hosts/m2-macbook-air.nix ];
      };
      "mac-vm" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = inputs;
        modules = [ ./darwin/hosts/mac-vm.nix ];
      };
      # mac-mini output -- used with CI
      "nix-mac-mini" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = inputs;
        modules = [ ./darwin/hosts/mac-mini.nix ];
      };
    };

    # nixos targets
    packages.nixosConfigurations = {
      nix-pomerium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./nixos/hosts/nix-pomerium/configuration.nix ];
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
    packages.homeConfigurations = {
      # Used in CI
      heywoodlh = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./roles/home-manager/linux.nix
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
            ];
            programs.zsh.initExtra = ''
              function docker {
                docker_bin="$(command which docker)"
                colima list | grep default | grep -q Running || colima start default &>/dev/null # Start/create default colima instance if not running/created
                $docker_bin $@
              }
            '';
          }
        ];
        extraSpecialArgs = inputs;
      };
      heywoodlh-server = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./roles/home-manager/linux.nix
          {
            home = {
              username = "heywoodlh";
              homeDirectory = "/home/heywoodlh";
            };
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
            # Get rid of stuff from linux.nix that we don't want
            dconf.settings = pkgs.lib.mkForce {
            };

            # Disable Starship
            programs.starship.enable = pkgs.lib.mkForce false;

            home.packages = with pkgs; lib.mkForce [
              _1password
              ansible
              curl
              git
              glow
              htop
              jq
              k9s
              kubectl
              lefthook
              libvirt
              openssh
              pandoc
              tcpdump
              tmux
              tree
              w3m
              vim
              zsh
            ];

            programs.alacritty = pkgs.lib.mkForce {
              enable = false;
            };

            programs.firefox = pkgs.lib.mkForce {
              enable = false;
            };

            programs.vim.enable = true;
          }
        ];
        extraSpecialArgs = inputs;
      };
    };
  });
}
