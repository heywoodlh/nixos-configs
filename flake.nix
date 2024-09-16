{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Separate input for overriding
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";
    myFlakes = {
      url = "github:heywoodlh/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-23.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    ssh-keys = {
      url = "https://github.com/heywoodlh.keys";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mullvad-browser-home-manager = {
      url = "github:heywoodlh/home-manager/mullvad-browser-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    osquery-fix-nixpkgs = {
      url = "github:nixos/nixpkgs/e4235192047a058776b3680f559579bf885881da";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    spicetify.url = "gitlab:heywoodlh/spicetify-nix/macos-updates-fix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dark-wallpaper = {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/wallpapers/nix-wallpaper-dracula.png";
      flake = false;
    };
    light-wallpaper = {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/wallpapers/nix-wallpaper-simple-light-gray.png";
      flake = false;
    };
    snowflake = {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/logo/white.png";
      flake = false;
    };
    cosmic-session = {
      url = "github:pop-os/cosmic-session";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic.url = "github:zhaofengli/attic/6eabc3f02fae3683bffab483e614bebfcd476b21";
    nixos-x13s.url = "git+https://codeberg.org/adamcstephens/nixos-x13s";
    ts-warp-nixpkgs.url = "github:heywoodlh/nixpkgs/ts-warp-init";
    qutebrowser = {
      url = "github:qutebrowser/qutebrowser";
      flake = false;
    };
    dev-container = {
      url = "github:heywoodlh/dockerfiles?dir=dev";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        myFlakes.follows = "myFlakes";
      };
    };
    zen-browser.url = "github:heywoodlh/flakes?dir=zen-browser";
    signal-ntfy.url = "github:heywoodlh/signal-ntfy-mirror";
  };

  outputs = inputs@{ self,
                      nixpkgs,
                      nixpkgs-stable,
                      myFlakes,
                      nixpkgs-backports,
                      nixpkgs-lts,
                      nixos-wsl,
                      darwin,
                      home-manager,
                      mullvad-browser-home-manager,
                      jovian-nixos,
                      nur,
                      flake-utils,
                      spicetify,
                      nixos-hardware,
                      ssh-keys,
                      osquery-fix-nixpkgs,
                      flatpaks,
                      nix-on-droid,
                      dark-wallpaper,
                      light-wallpaper,
                      snowflake,
                      hyprland,
                      cosmic-session,
                      attic,
                      ts-warp-nixpkgs,
                      qutebrowser,
                      dev-container,
                      zen-browser,
                      signal-ntfy,
                      ... }:
  flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      arch = pkgs.stdenv.hostPlatform.uname.processor;
      linuxSystem = "${arch}-linux"; # set linuxSystem for MacOS linux-builder
      darwinSystem = "${arch}-darwin";
      darwinStateVersion = 4;
      darwinModules.heywoodlh.darwin = ./darwin/modules/default.nix;
      homeModules.heywoodlh.home = ./home/modules/default.nix;

      darwinConfig = machineType: myHostname: extraConf: darwin.lib.darwinSystem {
        system = "${darwinSystem}";
        specialArgs = inputs;
        modules = [
          darwinModules.heywoodlh.darwin
          ./darwin/roles/base.nix
          ./darwin/roles/defaults.nix
          ./darwin/roles/pkgs.nix
          ./darwin/roles/network.nix
          ./home/darwin/settings.nix
          extraConf
          {
            networking.hostName = myHostname;
            heywoodlh.darwin.sketchybar.enable = true;
            heywoodlh.darwin.yabai.enable = true;

            system.stateVersion = darwinStateVersion;
          }
        ] ++ pkgs.lib.optionals pkgs.stdenv.isAarch64 [ ./darwin/roles/m1.nix ];
      };

      eval = pkgs.lib.evalModules {
        specialArgs = { inherit pkgs; };
        modules = [
          darwinModules.heywoodlh.darwin { config._module.check = false; }
          homeModules.heywoodlh.home { config._module.check = false; }
        ];
      };

      # https://github.com/NixOS/nixpkgs/issues/293510
      cleanEval = pkgs.lib.filterAttrsRecursive (n: v: n != "_module") eval;

      optionsDoc = pkgs.nixosOptionsDoc {
        inherit (cleanEval) options;
      };

      myDevContainer = dev-container.packages.${linuxSystem}.dockerImage;
      anonScript = pkgs.writeShellScriptBin "anon" ''
        ${pkgs.docker-client}/bin/docker image ls | grep -q 'heywoodlh/dev' || ${pkgs.docker-client}/bin/docker load -i ${myDevContainer}
        ${pkgs.docker-client}/bin/docker network ls | grep -i socks-anon || ${pkgs.docker-client}/bin/docker network create socks-anon
        ${pkgs.docker-client}/bin/docker ps -a | grep -q tor-socks-proxy && ${pkgs.docker-client}/bin/docker rm -f tor-socks-proxy
        ${pkgs.docker-client}/bin/docker run -d --name=tor-socks-proxy --network=socks-anon docker.io/heywoodlh/tor-socks-proxy:latest
        ${pkgs.docker-client}/bin/docker run --network=socks-anon -it --rm -e SSH_TTY=true -e http_proxy="socks://tor-socks-proxy:9150" -e https_proxy="socks://tor-socks-proxy:9150" -e all_proxy="socks://tor-socks-proxy:9150" -e no_proxy="localhost,127.0.0.1,100.64.0.0/10,.barn-banana.ts.net" heywoodlh/dev:latest
        ${pkgs.docker-client}/bin/docker rm -f tor-socks-proxy
        ${pkgs.docker-client}/bin/docker network rm -f socks-anon
      '';
    in {
      formatter = pkgs.alejandra;
      # custom nix-darwin modules
      darwinModules.heywoodlh.darwin = self.darwinModules.heywoodlh.darwin;
      # macos targets
      packages.darwinConfigurations = {
        # Invoke darwinConfig like this:
        # "<hostname>" = darwinConfig "<hardwareType>" "<hostname>" { <extraAttrs> };
        # hardwareType can currently be "macbook" or "mac-mini"
        "m3-macbook-pro" = darwinConfig "macbook" "m3-macbook-pro" {
          homebrew = {
            brews = [
              "libolm"
            ];
            casks = [
              "beeper"
              "diffusionbee"
              "discord"
              "signal"
              "vmware-fusion"
              "zoom"
            ];
            masApps = {
              "Screens 5: VNC Remote Desktop" = 1663047912;
            };
          };
          home-manager.users.heywoodlh = {
            home.packages = with pkgs; [
              anonScript
            ];
            heywoodlh.home.applications = [
              {
                name = "Spotify";
                command = "${spicetify.packages.${system}.nord}/bin/spotify";
              }
              {
                name = "Moonlight";
                command = "${pkgs.moonlight-qt}/bin/moonlight";
              }
            ];
            programs.qutebrowser.settings = {
              content.proxy = "socks://nix-nvidia:1080/";
            };
          };
        };

        "mac-mini" = darwinConfig "mac-mini" "mac-mini" {
          imports = [
            ./darwin/roles/mac-mini.nix
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
            ./nixos/hosts/xps-13/configuration.nix
          ];
        };
        nixos-usb = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = inputs;
          modules = [
            (nixpkgs + "/nixos/modules/profiles/all-hardware.nix")
            /etc/nixos/hardware-configuration.nix
            ./nixos/desktop.nix
            {
              networking.hostName = "nixos-usb";
              # Bootloader
              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = false;
              # Enable networking
              networking.networkmanager.enable = true;
              # Set your time zone.
              time.timeZone = "America/Denver";
              # Select internationalisation properties.
              i18n.defaultLocale = "en_US.utf8";
              system.stateVersion = "24.05";
            }
          ];
        };
        nixos-mac-mini = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/hosts/m1-mac-mini.nix
            ./nixos/server.nix
            ./nixos/roles/media/plex.nix
            ./nixos/roles/monitoring/iperf.nix
            ./nixos/roles/nixos/asahi.nix
            {
              networking.hostName = "nixos-mac-mini";
              system.stateVersion = "24.05";
              # Virtual machine media
              fileSystems."/media/virtual-machines" = {
                device = "/dev/disk/by-uuid/2fa5a6c4-b938-4853-844d-c85a77ae33e7";
                fsType = "ext4";
                options = [ "rw" "relatime" ];
              };
              # Bootloader.
              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = false;
              # Enable networking
              networking.networkmanager.enable = true;
              # Set your time zone.
              time.timeZone = "America/Denver";
              # Select internationalisation properties.
              i18n.defaultLocale = "en_US.utf8";
            }
          ];
        };
        nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = inputs;
          modules = [ ./nixos/hosts/wsl.nix ];
        };
        nixos-arm64-vm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [ ./nixos/hosts/nixos-arm64-vm/configuration.nix ];
        };
        nixos-arm64-test = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [ ./nixos/hosts/nixos-arm64-test/configuration.nix ];
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
          modules = [
            ./nixos/hosts/nix-nvidia/configuration.nix
            {
              home-manager.users.heywoodlh = {
                home.packages = with pkgs; [
                  anonScript
                ];
              };
            }
          ];
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
        nixos-lima-vm = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
            (myFlakes + "/lima/lima-init.nix")
            (myFlakes + "/lima/configuration.nix")
            ./nixos/server.nix
            {
              networking.hostName = "nixos-lima-vm";
              system.stateVersion = "24.05";
            }
          ];
        };
        # Console
        nixos-console = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/console.nix
            /etc/nixos/hardware.nix
            {
              networking.hostName = "nixos-console";
            }
          ];
        };
        # MicroPC
        nixos-p8 = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/desktop.nix
            ./nixos/hosts/p8.nix
            ./nixos/roles/remote-access/sshd.nix
            {
              networking.hostName = "nixos-p8";
              boot.initrd.clevis.enable = true;
              environment.systemPackages = with pkgs; [
                clevis
              ];
              # Use the systemd-boot EFI boot loader.
              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;
              boot.kernelParams = [
                "i915.force_probe=46d1"
              ];
              home-manager.users.heywoodlh.imports = [
                ./home/roles/gnome-terminal-fullscreen.nix
              ];
              # Yubikey support
              boot.initrd.luks.yubikeySupport = true;
              security.pam.yubico = {
                enable = true;
                mode = "challenge-response";
                id = [ "22698293" ];
              };
            }
          ];
        };
        # Dev VM for running on workstations
        nixos-dev = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/vm.nix
            {
              networking.hostName = "nixos-dev";
            }
          ];
        };
        # VMWare VM for running on workstations
        nixos-vmware = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/vm.nix
            {
              networking.hostName = "nixos-vmware";
              virtualisation.vmware.guest.enable = true;
              console.earlySetup = true;
              services.tailscale.enable = pkgs.lib.mkForce false;
            }
          ];
        };
        nixos-gaming = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/server.nix
            ./nixos/roles/gaming/palworld.nix
            /etc/nixos/hardware-configuration.nix
            {
              networking.hostName = "nixos-gaming";
              boot.loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
              };
              system.stateVersion = "24.05";
            }
          ];
        };
        # UTM VM for running on MacOS
        nixos-utm = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/vm.nix
            (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
            {
              networking.hostName = "nixos-utm";
              services.qemuGuest.enable = true;
              virtualisation.rosetta.enable = pkgs.stdenv.hostPlatform.isAarch64;
              services.tailscale.enable = pkgs.lib.mkForce false;
            }
          ];
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
            (mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
            flatpaks.homeManagerModules.default
            ./home/linux.nix
            ./home/desktop.nix # Base desktop config
            ./home/linux/desktop.nix # Linux-specific desktop config
            ./home/linux/gnome-desktop.nix
            (import myFlakes.packages.${system}.gnome-dconf)
            {
              # Home-Manager specific nixpkgs config
              nixpkgs.config = {
                allowUnfree = true;
                # Allow olm for gomuks until issues are resolved
                permittedInsecurePackages = [
                  "olm-3.2.16"
                ];
              };
              home = {
                username = "heywoodlh";
                homeDirectory = "/home/heywoodlh";
              };
              fonts.fontconfig.enable = true;
              programs.home-manager.enable = true;
              targets.genericLinux.enable = true;
              home.packages = [
                pkgs.docker-client
                (pkgs.nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "JetBrainsMono" ]; })
                myFlakes.packages.${system}.git
                myFlakes.packages.${system}.vim
              ];
              home.file."bin/create-docker" = {
                enable = true;
                executable = true;
                text = ''
                  #!/usr/bin/env bash
                  ${pkgs.lima}/bin/limactl list | grep default | grep -q Running || ${pkgs.lima}/bin/limactl start --name=default template://docker # Start/create default lima instance if not running/created
                  ${pkgs.docker-client}/bin/docker context create lima-default --docker "host=unix:///Users/heywoodlh/.lima/default/sock/docker.sock"
                  ${pkgs.docker-client}/bin/docker context use lima-default
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
                    if [[ "$version" == "24.04" ]]
                    then
                      EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-24.05"
                    fi
                  fi
                  nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage" --impure $EXTRA_ARGS
                '';
              };
            }
            #hyprland.homeManagerModules.default
            #./home/linux/hyprland.nix
          ];
          extraSpecialArgs = inputs;
        };
        heywoodlh-server = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/linux.nix
            ./home/linux/no-desktop.nix
            {
              # Home-Manager specific nixpkgs config
              nixpkgs.config = {
                allowUnfree = true;
                # Allow olm for gomuks until issues are resolved
                permittedInsecurePackages = [
                  "olm-3.2.16"
                ];
              };
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
      packages.nixOnDroidConfigurations = {
        default = nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs = inputs;
          modules = [ ./nixos/droid.nix ];
          home-manager-path = home-manager.outPath;
        };
      };
      packages = {
        docs = pkgs.runCommand "options-doc.md" {} ''
          cat ${optionsDoc.optionsCommonMark} | ${pkgs.gnused}/bin/sed -E 's|file://||g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/darwin\/modules|https:\/\/github.com\/heywoodlh\/nixos-configs\/tree\/master\/darwin\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/nixos\/modules|https:\/\/github.com\/heywoodlh\/nixos-configs\/tree\/master\/nixos\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/home\/modules|https:\/\/github.com\/heywoodlh\/nixos-configs\/tree\/master\/home\/modules|g' > $out
        '';
      };

      devShell = pkgs.mkShell {
        name = "nixos-configs devShell";
        buildInputs = with pkgs; [
          lefthook
        ];
      };
    }
  );
}
