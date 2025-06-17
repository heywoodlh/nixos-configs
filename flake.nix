{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Separate input for overriding
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-pam-lid-fix.url = "github:heywoodlh/nixpkgs/lid-close-fprint-disable";
    nixpkgs-apple-containers.url = "github:xiaoxiangmoe/nixpkgs/container";
    # identify possible nvidia versions here:
    # https://github.com/icewind1991/nvidia-patch-nixos/blob/main/patch.json
    # if errors encountered, search for commits with the previous version
    # i.e. https://github.com/NixOS/nixpkgs/pulls?q=565.57.01
    nixpkgs-nvidia.url = "github:nixos/nixpkgs/e718ed96ed39ece6433b965b1b1479b8878a29a3";
    determinate-nix.url = "github:DeterminateSystems/nix/v2.28.1";
    myFlakes = {
      url = "github:heywoodlh/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-24.11";
    x270-fingerprint-driver = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
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
    #mullvad-browser-home-manager = {
    #  url = "github:heywoodlh/home-manager/mullvad-browser-support";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    osquery-fix-nixpkgs = {
      url = "github:nixos/nixpkgs/e4235192047a058776b3680f559579bf885881da";
    };
    hyprland.url = "github:hyprwm/Hyprland?submodules=1";
    # Fetch the "development" branch of the Jovian-NixOS repository (Steam Deck)
    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    spicetify = {
      url = "gitlab:kylesferrazza/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    attic.url = "github:zhaofengli/attic/6eabc3f02fae3683bffab483e614bebfcd476b21";
    ts-warp-nixpkgs.url = "github:heywoodlh/nixpkgs/ts-warp-init";
    qutebrowser = {
      url = "github:qutebrowser/qutebrowser";
      flake = false;
    };
    signal-ntfy.url = "github:heywoodlh/signal-ntfy-mirror";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    proxmox-nixos.url = "github:heywoodlh/proxmox-nixos";
    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs-nvidia";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    cart = {
      url = "github:heywoodlh/cart";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "darwin";
    };
  };

  outputs = inputs@{ self,
                      nixpkgs,
                      nixpkgs-stable,
                      nixpkgs-pam-lid-fix,
                      nixpkgs-apple-containers,
                      myFlakes,
                      nixpkgs-backports,
                      nixpkgs-lts,
                      nixos-wsl,
                      darwin,
                      home-manager,
                      #mullvad-browser-home-manager,
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
                      nixos-cosmic,
                      cosmic-manager,
                      attic,
                      ts-warp-nixpkgs,
                      qutebrowser,
                      signal-ntfy,
                      lanzaboote,
                      comin,
                      proxmox-nixos,
                      nvidia-patch,
                      plasma-manager,
                      ghostty,
                      determinate-nix,
                      cart,
                      x270-fingerprint-driver,
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
      arch = pkgs.stdenv.hostPlatform.uname.processor;
      linuxSystem = "${arch}-linux"; # set linuxSystem for MacOS linux-builder
      darwinSystem = "${arch}-darwin";
      darwinModules.heywoodlh.darwin = ./darwin/modules/default.nix;
      homeModules.heywoodlh.home = ./home/modules/default.nix;

      darwinConfig = machineType: myHostname: extraConf: darwin.lib.darwinSystem {
        system = "${darwinSystem}";
        specialArgs = inputs;
        modules = [
          darwinModules.heywoodlh.darwin
          determinate-nix.darwinModules.default
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

      #myDevContainer = dev-container.packages.${linuxSystem}.dockerImage;
      #anonScript = pkgs.writeShellScriptBin "anon" ''
      #  ${pkgs.docker-client}/bin/docker image ls | grep -q 'heywoodlh/dev' || ${pkgs.docker-client}/bin/docker load -i ${myDevContainer}
      #  ${pkgs.docker-client}/bin/docker network ls | grep -i socks-anon || ${pkgs.docker-client}/bin/docker network create socks-anon
      #  ${pkgs.docker-client}/bin/docker ps -a | grep -q tor-socks-proxy && ${pkgs.docker-client}/bin/docker rm -f tor-socks-proxy
      #  ${pkgs.docker-client}/bin/docker run -d --name=tor-socks-proxy --network=socks-anon docker.io/heywoodlh/tor-socks-proxy:latest
      #  ${pkgs.docker-client}/bin/docker run --network=socks-anon -it --rm -e SSH_TTY=true -e http_proxy="socks://tor-socks-proxy:9150" -e https_proxy="socks://tor-socks-proxy:9150" -e all_proxy="socks://tor-socks-proxy:9150" -e no_proxy="localhost,127.0.0.1,100.64.0.0/10,.barn-banana.ts.net" heywoodlh/dev:latest
      #  ${pkgs.docker-client}/bin/docker rm -f tor-socks-proxy
      #  ${pkgs.docker-client}/bin/docker network rm -f socks-anon
      #'';
    proxmoxConfig = {
      imports = [
        proxmox-nixos.nixosModules.proxmox-ve
      ];
      services.proxmox-ve.enable = true;
      nixpkgs.overlays = [
        proxmox-nixos.overlays.${pkgs.system}
      ];
      nix.settings = {
        substituters = [ "https://cache.saumon.network/proxmox-nixos" ];
        trusted-public-keys = [ "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys=" ];
      };
      users.users.root.openssh.authorizedKeys.keys = [
        "from=\"100.109.183.68\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClbyKk9D4dWDO2fCNV8KbT8HyUzCmmyfuly4fWZ2R78frVJRpkeDJ3N9Km+Pegi13uwaky0NMDF5t5xTACgS8Z+J3z6v+f93OF32n+FMiBEIs+91PzUs9iFvlLSyN9WbQ1dxgJKAnJkuFle4tK1simK+EbO2kvtsT5h3XdMI0lVlg4lIUhz8KO81OcQJ+MLzwqrxg/AN+6uLan5oav72cpXD4fB/lJnfn33awg5MklPg/BSYD5pY5EvPFmiwaFZzppD7nO3KLoWgT5ksX+fTxpeFlfP525u31lMaHYQZiwIFDzCPyVsocP1dlfny0j25Cz3ycFk8wGUswMRfi6/WSj root@proxmox-mac-mini"
        "from=\"192.168.50.20\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClbyKk9D4dWDO2fCNV8KbT8HyUzCmmyfuly4fWZ2R78frVJRpkeDJ3N9Km+Pegi13uwaky0NMDF5t5xTACgS8Z+J3z6v+f93OF32n+FMiBEIs+91PzUs9iFvlLSyN9WbQ1dxgJKAnJkuFle4tK1simK+EbO2kvtsT5h3XdMI0lVlg4lIUhz8KO81OcQJ+MLzwqrxg/AN+6uLan5oav72cpXD4fB/lJnfn33awg5MklPg/BSYD5pY5EvPFmiwaFZzppD7nO3KLoWgT5ksX+fTxpeFlfP525u31lMaHYQZiwIFDzCPyVsocP1dlfny0j25Cz3ycFk8wGUswMRfi6/WSj root@proxmox-mac-mini"
        "from=\"100.79.151.6\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoCHYi25JA+QueyDNph6aGM+xPyDub3SQ8kj8sSy66O6YC7OH/CfRz6btRHff1PB8jtwxD4QUBvWaRKpKZB/2rZ/4i7yMULhAJlZkKyqnLl5QAvRMc21x0OlCSCXMpSbdSOwvfOouXLGCbBXS4n5L8+jKwUfZ06eM6V901KilymqMJiCQjFgrc0thlwyFUl2ZFeu+/H/UzhhBPWrrVDDq+RWbX34cI/qJrcvW4PYZYVKFBUXWy575C7ouIgdjeh3dQYNcPX6kaN56g/VawmfUxEDZoGhTzhU5rX4DBxTnL9Cp+sQkDXKNTK+TBAmM4JNg0tQbUv05Wi4LUTKD0vN4b root@proxmox-oryx-pro"
        "from=\"192.168.50.21\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoCHYi25JA+QueyDNph6aGM+xPyDub3SQ8kj8sSy66O6YC7OH/CfRz6btRHff1PB8jtwxD4QUBvWaRKpKZB/2rZ/4i7yMULhAJlZkKyqnLl5QAvRMc21x0OlCSCXMpSbdSOwvfOouXLGCbBXS4n5L8+jKwUfZ06eM6V901KilymqMJiCQjFgrc0thlwyFUl2ZFeu+/H/UzhhBPWrrVDDq+RWbX34cI/qJrcvW4PYZYVKFBUXWy575C7ouIgdjeh3dQYNcPX6kaN56g/VawmfUxEDZoGhTzhU5rX4DBxTnL9Cp+sQkDXKNTK+TBAmM4JNg0tQbUv05Wi4LUTKD0vN4b root@proxmox-oryx-pro"
        "from=\"100.108.77.60\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINY1Uh0d+CCNdWdnLa1R/1gIdVFWnOTQpu8AGtzvTbBH root@nix-nvidia"
        "from=\"192.168.50.22\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINY1Uh0d+CCNdWdnLa1R/1gIdVFWnOTQpu8AGtzvTbBH root@nix-nvidia"
      ];
    };
    # shared config among darwin workstations
    darwinWorkstationConfig = {
      homebrew = {
        brews = [
          "libolm"
        ];
        casks = [
          "beeper"
          "diffusionbee"
          "discord"
          "legcord"
          "signal"
          "vmware-fusion"
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
            name = "Spotify";
            command = "${spicetify.packages.${system}.nord}/bin/spotify";
          }
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
        "m3-macbook-pro" = darwinConfig "macbook" "m3-macbook-pro" {
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
        nixos-zenbook = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/hosts/zenbook-14/configuration.nix
          ];
        };
        nixos-thinkpad = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/hosts/thinkpad-x270/configuration.nix
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
        # generic build for CI
        nixos-server = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = inputs;
          modules = [ ./nixos/hosts/nixos-build/server.nix ];
        };
        # generic build for CI
        nixos-desktop = nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = inputs;
          modules = [ ./nixos/hosts/nixos-build/desktop.nix ];
        };
        nix-nvidia = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/hosts/nix-nvidia/configuration.nix
            #proxmoxConfig
          ];
        };
        nix-drive = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [ ./nixos/hosts/nix-drive/configuration.nix ];
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
        # Dev VM for running on workstations
        nixos-dev = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            /etc/nixos/hardware-configuration.nix
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
            /etc/nixos/hardware-configuration.nix
            ./nixos/vm.nix
            ./nixos/roles/hardware/printers.nix
            {
              networking.hostName = "nixos-vmware";
              virtualisation.vmware.guest.enable = true;
              console.earlySetup = true;
              services.tailscale.enable = pkgs.lib.mkForce false;
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
            }
          ];
        };
        nixos-gaming = nixpkgs.lib.nixosSystem {
          system = "${linuxSystem}";
          specialArgs = inputs;
          modules = [
            ./nixos/server.nix
            ./nixos/roles/gaming/palworld.nix
            ./nixos/hosts/nixos-gaming.nix
            {
              networking.hostName = "nixos-gaming";
              boot.loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
              };
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
        nixPkg = determinate-nix.packages.${system}.default;
      in {
        # Used in CI
        heywoodlh = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            determinate-nix.homeModules.default
            #(mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
            cosmic-manager.homeManagerModules.cosmic-manager
            flatpaks.homeManagerModules.declarative-flatpak
            ./home/linux.nix
            ./home/desktop.nix # Base desktop config
            ./home/linux/desktop.nix # Linux-specific desktop config
            (import myFlakes.packages.${system}.gnome-dconf)
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
            #hyprland.homeManagerModules.default
            #./home/linux/hyprland.nix
          ];
          extraSpecialArgs = inputs;
        };
        heywoodlh-server = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            determinate-nix.homeModules.default
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
          stable-pkgs.gitleaks # bug in pkgs.gitleaks currently
        ];
      };
    }
  );
}
