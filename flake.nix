{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Separate input for overriding
    myFlakes.url = "github:heywoodlh/flakes";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-vmware-aarch64.url = "github:heywoodlh/nixpkgs/aarch64-vmware-guest";
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
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
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
    choose-nixpkgs.url = "github:heywoodlh/nixpkgs/b0025018535256ce462b4aa2e39677eb110d38b2";
    cosmic-session = {
      url = "github:pop-os/cosmic-session";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic.url = "github:zhaofengli/attic/6eabc3f02fae3683bffab483e614bebfcd476b21";
    nixos-x13s.url = "git+https://codeberg.org/adamcstephens/nixos-x13s";
    openbar-nixpkgs.url = "github:heywoodlh/nixpkgs/openbar-init";
  };

  outputs = inputs@{ self,
                      nixpkgs,
                      myFlakes,
                      nixpkgs-stable,
                      nixpkgs-backports,
                      nixpkgs-lts,
                      nixpkgs-vmware-aarch64,
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
                      choose-nixpkgs,
                      cosmic-session,
                      attic,
                      openbar-nixpkgs,
                      ... }:
  flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      arch = pkgs.stdenv.hostPlatform.uname.processor;
      linuxSystem = "${arch}-linux"; # set linuxSystem for MacOS linux-builder
      darwinSystem = "${arch}-darwin";
      darwinStateVersion = 4;
      darwinModules.heywoodlh.darwin = ./darwin/modules/default.nix;

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
        ];
      };

      optionsDoc = pkgs.nixosOptionsDoc {
        inherit (eval) options;
      };
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
              "docker"
              "signal"
              "vmware-fusion"
              "zoom"
            ];
            masApps = {
              "Screens 5: VNC Remote Desktop" = 1663047912;
            };
          };
          home-manager.users.heywoodlh.home.packages = with pkgs; [
            moonlight-qt
            spicetify.packages.${system}.nord
          ];
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
            nixos-hardware.nixosModules.dell-xps-13-9310
            ./nixos/hosts/xps.nix
          ];
        };
        nixos-thinkpad = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [
            inputs.nixos-x13s.nixosModules.default
            /etc/nixos/hardware-configuration.nix
            ./nixos/desktop.nix
            {
              nixos-x13s = {
                enable = true;
                kernel = "jhovold";
                bluetoothMac = "02:68:b3:29:da:98";
              };
              specialisation = {
                mainline.configuration.nixos-x13s.kernel = "jhovold";
              };
              nix.settings = {
                substituters = [
                  "https://heywoodlh-nixos-x13s.cachix.org"
                ];
                trusted-public-keys = [
                  "heywoodlh-nixos-x13s.cachix.org-1:nittOYRA74tbzQ1s92ZQbN61ecxo7Ld16LK3g+CPPSE="
                ];
              };

              networking.hostName = "nixos-thinkpad";
              # Bootloader
              boot.loader.systemd-boot.enable = true;
              # Enable networking
              networking.networkmanager.enable = true;
              # Set your time zone.
              time.timeZone = "America/Denver";
              # Select internationalisation properties.
              i18n.defaultLocale = "en_US.utf8";

              # Fingerprint
              services.fprintd.enable = true;
              services.fprintd.tod.enable = true;
              services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

              # Network manager modemmanager setup
              networking.networkmanager.fccUnlockScripts = [
                {
                  id = "105b:e0c3";
                  path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
                }
              ];

              environment.systemPackages = with pkgs; [
                webcord
              ];

              system.stateVersion = "24.05";
            }
          ];
        };
        nixos-oryx-pro = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            /etc/nixos/hardware-configuration.nix
            ./nixos/server.nix
            {
              networking.hostName = "nixos-oryx-pro";
              # System76 stuff
              hardware.system76.enableAll = true;
              services.system76-scheduler.enable = true;
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
              # Nvidia
              boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;
              # Make sure opengl is enabled
              hardware.opengl = {
                enable = true;
                driSupport = true;
                driSupport32Bit = true;
              };
              hardware.nvidia = {
                modesetting.enable = true;
                open = false;
                nvidiaSettings = true;
                package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11;
              };
              services.openssh = {
                extraConfig = ''
                  HostKeyAlgorithms +ssh-rsa
                  PubkeyAcceptedKeyTypes +ssh-rsa
                '';
                settings = {
                  PasswordAuthentication = pkgs.lib.mkForce true;
                  Macs = [
                    "hmac-sha2-512-etm@openssh.com"
                    "hmac-sha2-256-etm@openssh.com"
                    "umac-128-etm@openssh.com"
                    "hmac-sha2-256"
                  ];
                };
              };
            }
          ];
        };
        nixos-mac-mini = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/hosts/m1-mac-mini/configuration.nix
            ./nixos/server.nix
            ./nixos/roles/media/plex.nix
            ./nixos/roles/monitoring/iperf.nix
            {
              networking.hostName = "nixos-mac-mini";
              system.stateVersion = "24.05";
              # Virtual machine media
              fileSystems."/media/virtual-machines" = {
                device = "/dev/disk/by-uuid/2fa5a6c4-b938-4853-844d-c85a77ae33e7";
                fsType = "ext4";
                options = [ "rw" "relatime" ];
              };
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
          modules = [ ./nixos/hosts/nix-nvidia/configuration.nix ];
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
              # Increase font size for high resolution on Macs
              home-manager.users.heywoodlh.dconf.settings = {
                "apps/guake/style/font".style = pkgs.lib.mkForce "JetBrains Mono 18";
                "org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d86" = {
                  font = pkgs.lib.mkForce "JetBrains Mono NL 18";
                };
              };
              services.tailscale.enable = pkgs.lib.mkForce false;
              imports = [
                (nixpkgs-vmware-aarch64 + "/nixos/modules/virtualisation/vmware-guest.nix")
              ];
              disabledModules = ["virtualisation/vmware-guest.nix"];
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
                    ## TODO: Support Ubuntu 24.04 when released
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
      packages.docs = pkgs.runCommand "options-doc.md" {} ''
        cat ${optionsDoc.optionsCommonMark} > $out
      '';
      devShell = pkgs.mkShell {
        name = "nixos-configs devShell";
        buildInputs = with pkgs; [
          lefthook
        ];
      };
    }
  );
}
