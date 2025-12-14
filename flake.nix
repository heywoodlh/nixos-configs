{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Separate input for overriding
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-pam-lid-fix.url = "github:heywoodlh/nixpkgs/lid-close-fprint-disable";
    # only to sync dependents that use flake-utils
    flake-utils.url = "github:numtide/flake-utils";
    # only to sync dependents that use flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    # only to sync dependents that use nix
    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "kyle/flake-compat";
      inputs.git-hooks-nix.follows = "pre-commit-hooks";
    };
    determinate = {
      url = "github:DeterminateSystems/nix/v2.28.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix.follows = "nix";
    };
    # for dependents of crane
    crane.url = "github:ipetkov/crane";
    # for dependents of helix-src
    helix-src = {
      url = "github:heywoodlh/helix/issue-2719";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    myFlakes = {
      url = ./flakes;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.helix-src.follows = "helix-src";
    };
    # for dependents of ashell
    ashell = {
      url = "github:kylesferrazza/ashell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "helix-src/rust-overlay";
    };
    # for dependents of devenv
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nix.follows = "nix";
      inputs.git-hooks.follows = "pre-commit-hooks";
      inputs.flake-compat.follows = "kyle/flake-compat";
    };
    kyle = {
      url = "gitlab:heywoodlh/nix-configs/asahi-fw-hashes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.ashell.follows = "ashell";
      inputs.devenv.follows = "devenv";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "darwin";
      inputs.nur.follows = "nur";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.flake-compat.follows = "kyle/flake-compat";
    };
    user-icon = {
      url = "https://avatars.githubusercontent.com/u/18178614?v=4";
      flake = false;
    };
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
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dark-wallpaper = {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/wallpapers/nix-wallpaper-dracula.png";
      flake = false;
    };
    light-wallpaper = {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/wallpapers/nix-wallpaper-simple-light-gray.png";
      flake = false;
    };
    signal-ntfy = {
      url = "github:heywoodlh/signal-ntfy-mirror";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    cart = {
      url = "github:heywoodlh/cart";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "darwin";
      inputs.flake-utils.follows = "flake-utils";
    };
    hexstrike-ai = {
      url = "github:heywoodlh/hexstrike-ai/nix-flake-init";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # only to sync dependents that use pre-commit-hooks
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "kyle/flake-compat";
    };
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    # only for dependents that use nmd
    nmd = {
      url = "sourcehut:~rycee/nmd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # only for dependents that use nix-formatter-pack
    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nmd.follows = "nmd";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-formatter-pack.follows = "nix-formatter-pack";
      inputs.nmd.follows = "nmd";
    };
  };

  outputs = inputs@{ self,
                      nixpkgs,
                      nixpkgs-stable,
                      nixpkgs-pam-lid-fix,
                      myFlakes,
                      kyle,
                      nixpkgs-backports,
                      nixpkgs-lts,
                      nixos-wsl,
                      darwin,
                      home-manager,
                      jovian-nixos,
                      nur,
                      flake-utils,
                      nixos-hardware,
                      ssh-keys,
                      user-icon,
                      osquery-fix-nixpkgs,
                      dark-wallpaper,
                      light-wallpaper,
                      signal-ntfy,
                      plasma-manager,
                      determinate,
                      cart,
                      hexstrike-ai,
                      hyprland,
                      nix-on-droid,
                      ... }:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    stable-pkgs = import nixpkgs-stable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    lib = pkgs.lib;
    arch = pkgs.stdenv.hostPlatform.uname.processor;
    linuxSystem = "${arch}-linux"; # set linuxSystem for MacOS linux-builder
    darwinSystem = "${arch}-darwin";
    darwinModules.heywoodlh.darwin = ./darwin/modules/default.nix;
    homeModules.heywoodlh.home = ./home/modules/default.nix;
    extNixOSModules = [
      determinate.nixosModules.default
      home-manager.nixosModules.home-manager
      kyle.nixosModules.apple-silicon-support
      kyle.nixosModules.appleSilicon
    ];
    myNixOSModules = [
      ./nixos/modules/defaults.nix
      ./nixos/modules/gnome.nix
      ./nixos/modules/hyprland.nix
      ./nixos/modules/intel-mac.nix
      ./nixos/modules/workstation.nix
      ./nixos/modules/console.nix
      ./nixos/modules/server.nix
      ./nixos/modules/laptop.nix
      ./nixos/modules/cosmic.nix
      ./nixos/modules/vm.nix
      ./nixos/modules/sshd.nix
      ./nixos/modules/asahi.nix
    ];
    nixosModules.heywoodlh = { config, pkgs, ... }: {
      imports = myNixOSModules ++ extNixOSModules;
    };

    # for docs on my modules only
    nixosModules.docs = { config, pkgs, ... }: {
      imports = myNixOSModules;
    };

    darwinConfig = machineType: myHostname: extraConf: darwin.lib.darwinSystem {
      system = "${darwinSystem}";
      specialArgs = inputs;
      modules = [
        darwinModules.heywoodlh.darwin
        determinate.darwinModules.default
        home-manager.darwinModules.home-manager
        ./darwin/roles/base.nix
        ./darwin/roles/defaults.nix
        ./darwin/roles/pkgs.nix
        ./darwin/roles/network.nix
        extraConf
        {
          imports = [
            "${cart}/darwin.nix"
          ];
          # Import nur as nixpkgs.overlays
          nixpkgs.overlays = [
            nur.overlays.default
          ];
          home-manager.useGlobalPkgs = true;

          networking.hostName = myHostname;
          networking.computerName = myHostname;
          heywoodlh.darwin = {
            sketchybar.enable = true;
            yabai = {
              enable = true;
              homebrew = true;
            };
          };
          system.stateVersion = 6;
        }
      ] ++ pkgs.lib.optionals pkgs.stdenv.isAarch64 [ ./darwin/roles/m1.nix ];
    };

    nixosConfig = machineType: myHostname: extraConf: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [
        nixosModules.heywoodlh
        home-manager.nixosModules.home-manager
        ./nixos/roles/virtualization/multiarch.nix
        ./nixos/roles/nixos/attic.nix
        {
          heywoodlh.defaults = {
            enable = true;
            user = {
              name = "heywoodlh";
              description = "Spencer Heywood";
              uid = 1000;
              homeDir = "/home/heywoodlh";
            };
            hostname = myHostname;
          };
          home-manager.users.heywoodlh = { ... }: {
            imports = [
              homeModules.heywoodlh.home
            ];
          };
        }
        extraConf
      ] ++ lib.optionals (machineType == "server") [
        ./nixos/roles/security/sshd-monitor.nix
        ./nixos/roles/tailscale.nix
        ./nixos/roles/monitoring/syslog-ng/client.nix
        ./nixos/roles/monitoring/node-exporter.nix
        ./nixos/roles/backups/tarsnap.nix
        { heywoodlh.server = true; }
      ] ++ lib.optionals (machineType == "workstation") [
        { heywoodlh.workstation = true; }
      ] ++ lib.optionals (machineType == "laptop") [
        { heywoodlh.laptop = true; }
      ] ++ lib.optionals (machineType == "vm") [
        { heywoodlh.vm = true; }
      ] ++ lib.optionals (machineType == "console") [
        { heywoodlh.console = true; }
      ];
    };

    eval = pkgs.lib.evalModules {
      specialArgs = { inherit pkgs; };
      modules = [
        darwinModules.heywoodlh.darwin { config._module.check = false; }
        homeModules.heywoodlh.home { config._module.check = false; }
        nixosModules.docs { config._module.check = false; }
      ];
    };

    # https://github.com/NixOS/nixpkgs/issues/293510
    cleanEval = pkgs.lib.filterAttrsRecursive (n: v: n != "_module") eval;

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit (cleanEval) options;
    };

    # shared config among darwin workstations
    darwinWorkstationConfig = {
      homebrew = {
        brews = [
          "libolm"
        ];
        casks = [
          "beeper"
          "legcord"
          "windows-app"
          "zoom"
        ];
        masApps = {
          "Screens 5: VNC Remote Desktop" = 1663047912;
        };
      };
      home-manager.users.heywoodlh = {
        #home.packages = with pkgs; [
          #anonScript
        #];
        heywoodlh.home.applications = [
          {
            name = "Moonlight";
            command = "${pkgs.moonlight-qt}/bin/moonlight";
          }
        ];
      };
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
        "m4-macbook-air" = darwinConfig "macbook" "m4-macbook-air" {
          imports = [
            darwinWorkstationConfig
            {
              cart = {
                enable = true;
                user = "heywoodlh";
                package = cart.packages.${system}.cart;
                applications = [
                  {
                    url = "https://github.com/utmapp/UTM/releases/download/v4.6.4/UTM.dmg";
                    hash = "aad86726152b15a3e963cf778a0b0dfd8e818736b381aed2699d974a18845427";
                  }
                  {
                    url = "https://github.com/podman-desktop/podman-desktop/releases/download/v1.17.2/podman-desktop-1.17.2-universal.dmg";
                    hash = "d73c81a859f5792329818893736b28f8dd8a5243cca41c8573ed7c2095f69182";
                  }
                ];
              };
              homebrew.casks = [
                "steam"
              ];
            }
          ];
        };
        "m1-mac-mini" = darwinConfig "mac-mini" "m1-mac-mini" {
          imports = [
            ./darwin/roles/mac-mini.nix
            darwinWorkstationConfig
            {
              # Firewall needs to be lenient for VNC/SSH
              networking.applicationFirewall = {
                enable = lib.mkForce false;
                blockAllIncoming = lib.mkForce false;
                enableStealthMode = lib.mkForce false;
              };
              cart = {
                enable = true;
                user = "heywoodlh";
                package = cart.packages.${system}.cart;
                applications = [
                  {
                    url = "https://github.com/utmapp/UTM/releases/download/v4.6.4/UTM.dmg";
                    hash = "aad86726152b15a3e963cf778a0b0dfd8e818736b381aed2699d974a18845427";
                  }
                  {
                    url = "https://github.com/ibrahimcetin/reins/releases/download/v1.3.0/Reins-macOS.dmg";
                    hash = "8db9f87297f2b474f81cc07326304a4e4144465b31cfb0713aef4900cbdecb5a";
                  }
                ];
              };
            }
          ];
        };
        "mac-mini" = darwinConfig "mac-mini" "mac-mini" {
          imports = [
            ./darwin/roles/mac-mini.nix
            {
              homebrew.casks = [
                "windows-app"
              ];
            }
          ];
        };
      };

      # nixos targets
      packages.nixosConfigurations = {
        homelab = nixosConfig "server" "homelab" {
          imports = [
            ./nixos/hosts/homelab/configuration.nix
          ];
        };

        nixos-intel-mac-mini = nixosConfig "workstation" "nixos-intel-mac-mini" {
          imports = [
            ./nixos/hosts/intel-mac-mini.nix
            #./nixos/roles/monitoring/osquery.nix
          ];
          heywoodlh.intel-mac = true;
          heywoodlh.sshd.enable = true;
        };

        nixos-blade = nixosConfig "laptop" "nixos-blade" {
          imports = [
            ./nixos/hosts/razer-blade-14.nix
            ./nixos/roles/gaming/steam.nix
          ];
          hardware.openrazer = {
            enable = true;
            users = [
              "heywoodlh"
            ];
          };
          environment.systemPackages = with pkgs; [
            nvtopPackages.nvidia
          ];
          home-manager.users.heywoodlh = {
            wayland.windowManager.hyprland.extraConfig = ''
              # change monitor to high resolution, the last argument is the scale factor
              monitor = , highres, auto, 1.6
              # unscale XWayland
              xwayland {
                force_zero_scaling = true
              }
              # toolkit-specific scale
              env = GDK_SCALE,2
              env = XCURSOR_SIZE,24
            '';
          };
          # Nvidia settings
          boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
          hardware.graphics = {
            enable = true;
          };
          services.xserver.videoDrivers = ["nvidia"];
          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.finegrained = false;
            open = true;
            nvidiaSettings = true;
            package = pkgs.linuxKernel.packages.linux_zen.nvidiaPackages.beta;
          };
        };
        nixos-m1-mac-mini = nixosConfig "workstation" "nixos-m1-mac-mini" {
          imports = [
            ./nixos/hosts/m1-mac-mini.nix
            ./nixos/roles/gaming/steam.nix
          ];
          heywoodlh.sshd.enable = true;
          heywoodlh.apple-silicon = {
            enable = true;
            cachefile = "kernelcache.release.mac13g";
            hash = {
              cache = "sha256-SYR/EaaIDjeGfvhfzlTqgOihXNQQdBgqJbBJbq+wC9g=";
              firmware = "sha256-ydzrhKfH/8iYo1PyNDnXmjcniMaete8DnN/yXYJ7mT4=";
            };
          };
          # Bootloader
          boot.loader.efi.canTouchEfiVariables = pkgs.lib.mkForce false;
          home-manager.users.heywoodlh = {
            home.packages = with pkgs; [
              moonlight-qt
            ];
            wayland.windowManager.hyprland.extraConfig = ''
              # change monitor to high resolution, the last argument is the scale factor
              monitor = , highres, auto, 1
              # unscale XWayland
              xwayland {
                force_zero_scaling = true
              }
              # toolkit-specific scale
              env = GDK_SCALE,2
              env = XCURSOR_SIZE,24
            '';
          };
        };

        nixos-usb = nixosConfig "workstation" "nixos-usb" {
          imports = [
            (nixpkgs + "/nixos/modules/profiles/all-hardware.nix")
            /etc/nixos/hardware-configuration.nix
          ];
          boot.loader.efi.canTouchEfiVariables = pkgs.lib.mkForce false;
        };

        family-mac-mini = nixosConfig "workstation" "family-mac-mini" {
          imports = [
            ./nixos/hosts/family-mac-mini.nix
            ./nixos/roles/desktop/family.nix
            ./nixos/roles/monitoring/osquery.nix
          ];

          boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
          heywoodlh.sshd.enable = true;
          heywoodlh.intel-mac = true;
        };

        # generic build for initial setup
        nixos-init = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = inputs;
          modules = [
            ./nixos/roles/nixos/attic.nix
            /etc/nixos/hardware-configuration.nix
            /etc/nixos/configuration.nix
            {
              programs.neovim = {
                enable = true;
                vimAlias = true;
                viAlias = true;
              };
              environment.systemPackages = with pkgs; [
                git
                myFlakes.packages.${system}.helix
                msedit
                nano
              ];
              services.tailscale.enable = true;
            }
          ];
        };

        nixos-wsl = nixosConfig "workstation" "nixos-wsl" {
          imports = [ ./nixos/hosts/wsl.nix ];
        };

        # generic build for CI
        nixos-server = nixosConfig "server" "nixos-server" {
          imports = [ ./nixos/hosts/nixos-build/server.nix ];
        };

        # generic build for CI
        nixos-desktop = nixosConfig "desktop" "nixos-desktop" {
          imports = [ ./nixos/hosts/nixos-build/desktop.nix ];
        };

        # Console
        nixos-console = nixosConfig "console" "nixos-console" {
          imports = [ /etc/nixos/hardware.nix ];
          networking.hostName = "nixos-console";
        };

        # Dev VM for running on workstations
        nixos-dev = nixosConfig "vm" "nixos-dev" {
          imports = [
            /etc/nixos/hardware-configuration.nix
            ./nixos/vm.nix
          ];
        };

        # VMWare VM for running on workstations
        nixos-vmware = nixosConfig "vm" "nixos-vmware" {
          imports = [
            /etc/nixos/hardware-configuration.nix
            ./nixos/vm.nix
          ];
          virtualisation.vmware.guest.enable = true;
          console.earlySetup = true;
          fileSystems."/shared" = {
            device = ".host:/";
            fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse"; # "fuse.${pkgs.open-vm-tools}/bin/vmhgfs-fuse" does not work
            options = [
              "allow_other"
              "auto_unmount"
              "defaults"
              "gid=1000"
              "uid=1000"
              "umask=0022"
            ];
          };
          home-manager.users.heywoodlh = {
            home.file.".gitconfig" = {
              text = ''
                [safe]
                directory = "/shared/*";
              '';
            };
          };
        };

        # Generic UTM VM for running on any Mac
        nixos-utm = nixosConfig "vm" "nixos-utm" {
          imports = [
            ./nixos/vm.nix
            /etc/nixos/hardware-configuration.nix
            (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
          ];
          services.qemuGuest.enable = true;
        };
      };
      # home-manager targets (non NixOS/MacOS, ideally Arch Linux)
      packages.homeConfigurations = let
        homeSwitch = ''
          ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs ~/opt/nixos-configs &>/dev/null || true
          ## OS-specific support (mostly, Ubuntu vs anything else)
          ## Anything else will use nixpkgs-unstable
          EXTRA_ARGS=""
          if ${pkgs.gnugrep}/bin/grep -iq Ubuntu /etc/os-release
          then
            version="$(${pkgs.gnugrep}/bin/grep VERSION_ID /etc/os-release | ${pkgs.coreutils}/bin/cut -d'=' -f2 | ${pkgs.coreutils}/bin/tr -d '"')"
            ## Support for Ubuntu 22
            if echo "$version" | ${pkgs.gnugrep}/bin/grep -qE '22'
            then
              EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-22.05"
            fi
            ## Support for Ubuntu 23
            if echo "$version" | ${pkgs.gnugrep}/bin/grep -qE '23'
            then
              EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-23.05"
            fi
            ## Support for Ubuntu 24-25, TODO support 25 standalone after May 2025
            if echo "$version" | ${pkgs.gnugrep}/bin/grep -q '24|25'
            then
              EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-24.05"
            fi
          fi
        '';
        nixPkg = determinate.packages.${system}.default;
      in {
        # Used in CI
        heywoodlh = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            determinate.homeModules.default
            #(mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
            ./home/linux.nix
            ./home/desktop.nix # Base desktop config
            ./home/linux/desktop.nix # Linux-specific desktop config
            {
              heywoodlh.home.onepassword.enable = true;
              heywoodlh.home.gnome = true;
              # Home-Manager specific nixpkgs config
              nixpkgs.config = {
                allowUnfree = true;
                # Allow olm for gomuks until issues are resolved
                permittedInsecurePackages = [
                  "olm-3.2.16"
                ];
                overlays = [
                  nur.overlays.default
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
                pkgs.nerd-fonts.jetbrains-mono
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
                  ${homeSwitch}
                  ${nixPkg}/bin/nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage" $EXTRA_ARGS --impure $@
                '';
              };
            }
          ];
          extraSpecialArgs = inputs;
        };
        heywoodlh-server = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            determinate.homeModules.default
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
                overlays = [
                  nur.overlays.default
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
              home.file."bin/home-switch" = {
                enable = true;
                executable = true;
                text = ''
                  #!/usr/bin/env bash
                  ${homeSwitch}
                  ${nixPkg}/bin/nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.heywoodlh-server.activationPackage" $EXTRA_ARGS --impure $@
                '';
              };
              # Logbash wrapper
              home.file.".config/fish/config.fish" = {
                enable = true;
                text = ''
                  function logbash
                    kubectl exec -it -n monitoring $(kubectl get pods -A | grep -i logbash | awk '{print $2}') -- logbash $argv
                  end
                '';
              };
            }
          ];
          extraSpecialArgs = inputs;
        };
      };

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [
          {
            home-manager.config = { pkgs, ... }:
            {
              imports = [
                ./home/linux.nix
                ./home/linux/no-desktop.nix
              ];
            };
          }
        ];
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
          stable-pkgs.gitleaks # bug in pkgs.gitleaks currently
          pkgs.strip-ansi
        ];
      };
    }
  );
}
