{
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    nixpkgs-edge.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1";
    nixpkgs-nvidia.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    nixpkgs-lts.follows = "nixpkgs";
    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs-nvidia";
      inputs.utils.follows = "flake-utils";
    };
    nixpkgs-jovian-nixos.url = "github:NixOS/nixpkgs/56c02bc00adcf003215cc4bd996d6efaf4cff188";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nur.follows = "nur";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "flake-utils/systems";
    };
    darwin = {
      url = "github:heywoodlh/nix-darwin/heywoodlh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit.follows = "git-hooks";
      inputs.crane.follows = "crane";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    crane.url = "github:ipetkov/crane";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-asahi = {
      url = "github:sm-idk/steam-asahi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix-src = {
      url = "github:heywoodlh/helix/issue-2719";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    asahi-widevine = {
      url = "github:AsahiLinux/widevine-installer";
      flake = false;
    };
    lacros = {
      url = "https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-120.0.6098.0";
      flake = false;
    };
    vicinae-nix = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };
    user-icon = {
      url = "https://avatar.tangled.sh/1c796c57a7536e989ab09026df5f0fe7870be6217bc8ae642e48fa449de72f59/did:plc:ycnss4fntzi3rjuueb7loq3x?v=bafkreic";
      flake = false;
    };
    ssh-keys = {
      url = "https://github.com/heywoodlh.keys";
      flake = false;
    };
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-jovian-nixos";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dark-wallpaper = {
      url = ./assets/catppuccin-nix.png;
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
      inputs.flake-utils.follows = "flake-utils";
    };
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs-nvidia";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "";
    };
    tangled = {
      url = "git+https://tangled.org/tangled.org/core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
      inputs.gomod2nix.follows = "";
    };
    spindle-run = {
      url = "git+https://tangled.org/heywoodlh.io/spindle-run";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.tangled.follows = "tangled";
    };
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gh-gitignore = {
      url = "github:github/gitignore";
      flake = false;
    };
    nixtop-source = {
      url = "git+https://codeberg.org/kylesferrazza/nix-configs?ref=main&rev=289467371d81111509567e9d5199ab0c74f72317";
      flake = false;
    };
    opencode-ssh = {
      url = "github:snez/opencode-ssh";
      flake = false;
    };
    youtube-htpc = {
      url = "github:heywoodlh/HTPC-YT/nix-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypr-rdp = {
      url = "github:MuNeNICK/hypr-rdp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-edge";
    };
    tether = {
      url = "github:zackb/tether";
      inputs.nixpkgs.follows = "nixpkgs-edge";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs-edge";
      inputs.home-manager.follows = "home-manager";
      inputs.flake-parts.follows = "flake-parts";
    };
    search-tui = {
      url = "github:heywoodlh/search-tui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-llama = {
      url = "github:heywoodlh/nix-llama";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kyle = {
      url = "git+https://codeberg.org/kylesferrazza/nix-configs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-cachyos-kernel.follows = "nix-cachyos-kernel";
      inputs.nur.follows = "nur";
      inputs.teslamate-src.follows = "";
      inputs.opnix.follows = "";
      inputs.stylix.follows = "";
      inputs.doom-d.follows = "";
      inputs.vscode-server.follows = "";
      inputs.hermes-agent.follows = "hermes-agent";
      inputs.systems.follows = "flake-utils/systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
      inputs.tether.follows = "tether";
      inputs.disko.follows = "disko";
      inputs.flake-compat.follows = "";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.treefmt-nix.follows = "";
    };
  };

  nixConfig = {
    fallback = true;
    connect-timeout = 1;
    extra-substituters = [
      "https://nix-community.cachix.org"
      "http://attic.barn-banana.ts.net/nixos"
      "http://attic.barn-banana.ts.net/nix-darwin"
      "https://heywoodlh-helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos:4q9iokR56gpJfsHh0UKn9Hj1cPplvM879XVgnRstpNU="
      "nix-darwin:hBC1vKJgE6O9S5jiasCHUepCV/cBvUtPEtV2sumBF6A="
      "heywoodlh-helix.cachix.org-1:qHDV95nI/wX9pidAukzMzgeok1415rgjMAXinDsbb7M="
    ];
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    darwin,
    home-manager,
    ...
  }: let
    lib = nixpkgs.lib;
    nixConfig = import ./nix-config.nix;
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = f: lib.genAttrs systems (system: f system);
    mergedInputs = inputs.kyle.inputs // inputs;
    mkPkgs = source: system:
      import source {
        inherit system;
        config.allowUnfree = true;
      };
    mkMyPkgs = system:
      import ./pkgs {
        pkgs = mkPkgs nixpkgs system;
        inherit lib;
        inherit (inputs) helix-src asahi-widevine lacros;
        nixpkgs-stable = nixpkgs-stable;
      };
    commonModules = [
      ./base/defaults.nix
      ./base/stylix.nix
      ./base/sshd.nix
      ./base/nix-llama.nix
    ];
    commonHomeModules = [
      ./home/modules/base.nix
      ./home/modules/docker.nix
      ./home/modules/lima.nix
      ./home/modules/applications.nix
      ./home/modules/marp.nix
      ./home/modules/1password-docker-helper.nix
      ./home/modules/helix.nix
      ./home/modules/aerc.nix
      ./home/modules/ghostty.nix
      ./home/modules/gh.nix
      ./home/modules/librewolf.nix
      ./home/modules/llm.nix
      ./home/modules/btop.nix
      ./home/modules/cava.nix
      ./home/modules/git.nix
      ./home/modules/syncthing.nix
      ./home/modules/pandoc.nix
      ./home/modules/paseo.nix
      ./home/modules/onepassword.nix
      ./home/modules/llm-agents.nix
      ./home/modules/search-tui.nix
      ./home/modules/kiwix.nix
      ./home/modules/spotify-soloist.nix
    ];
    linuxHomeModules = [
      ./home/modules/gnome.nix
      ./home/modules/cosmic.nix
      ./home/modules/guake.nix
      ./home/modules/niri.nix
      ./home/modules/hyprland.nix
      ./home/modules/hyprland-windows-mode.nix
      ./home/modules/vicinae.nix
      ./home/modules/linux-autostart.nix
      ./home/modules/bluetuith.nix
      ./home/modules/kde-windows.nix
      ./home/modules/hypr-rdp.nix
      ./home/modules/keyring.nix
    ];
    macosHomeModules = [
      ./home/modules/darwin-defaults.nix
      ./home/modules/disable-spotlight.nix
      ./home/modules/nord-terminal.nix
      ./home/modules/darwin-protondrive-link.nix
    ];
    allHomeModules = commonHomeModules ++ linuxHomeModules ++ macosHomeModules;
    extHomeModules = [inputs.hermes-agent.homeManagerModules.default];
    homeModule = {osClass ? "nixos", ...}: {
      imports =
        commonHomeModules
        ++ extHomeModules
        ++ lib.optionals (osClass == "nixos") (linuxHomeModules ++ [inputs.noctalia.homeModules.default])
        ++ lib.optionals (osClass == "darwin") macosHomeModules;
    };
    myNixOSModules =
      [
        ./nixos/modules/defaults.nix
        ./nixos/modules/gnome.nix
        ./nixos/modules/niri.nix
        ./nixos/modules/hyprland.nix
        ./nixos/modules/intel-mac.nix
        ./nixos/modules/workstation.nix
        ./nixos/modules/console.nix
        ./nixos/modules/server.nix
        ./nixos/modules/laptop.nix
        ./nixos/modules/cosmic.nix
        ./nixos/modules/vm.nix
        ./nixos/modules/helix.nix
        ./nixos/modules/luks.nix
        ./nixos/modules/fprint-lid.nix
        ./nixos/modules/backups.nix
        ./nixos/modules/cloudflared.nix
        ./nixos/modules/rayhunter.nix
        ./nixos/modules/stylix.nix
        ./nixos/modules/sunshine.nix
        ./nixos/modules/spotifyd.nix
        ./nixos/modules/spotify-soloist.nix
        ./nixos/modules/nvidia-patch.nix
        ./nixos/modules/gaming.nix
        ./nixos/modules/cachyos-kernel.nix
        ./nixos/modules/steam-deck.nix
        ./nixos/modules/vmware-workstation.nix
        ./nixos/modules/scrutiny.nix
        ./nixos/modules/remote-desktop.nix
        ./nixos/modules/kde.nix
        ./nixos/modules/tor.nix
        ./nixos/modules/portmaster.nix
        ./nixos/modules/lancache-dns.nix
        ./nixos/modules/tether.nix
        ./nixos/modules/libvirtd.nix
        ./nixos/modules/tv.nix
        ./nixos/modules/moonlight.nix
        ./nixos/modules/sshd.nix
        ./nixos/modules/asahi.nix
      ]
      ++ commonModules;
    extNixOSModules = [
      home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.kyle.nixosModules.appleSilicon
      inputs.jovian-nixos.nixosModules.default
      inputs.steam-asahi.nixosModules.default
      inputs.tether.nixosModules.default
    ];
    darwinModule = {...}: {
      imports =
        [
          ./darwin/modules/defaults.nix
          ./darwin/modules/sketchybar.nix
          ./darwin/modules/yabai.nix
          ./darwin/modules/stage-manager.nix
          ./darwin/modules/choose-launcher.nix
          ./darwin/modules/raycast.nix
          ./darwin/modules/stylix.nix
          ./darwin/modules/lmstudio.nix
        ]
        ++ commonModules;
    };
    nixosModule = {...}: {
      imports = myNixOSModules ++ extNixOSModules;
    };
    mkNixos = name: {
      system,
      type ? "workstation",
      flake ? nixpkgs,
      bare ? false,
    }:
      flake.lib.nixosSystem {
        inherit system;
        specialArgs =
          mergedInputs
          // {
            inputs = mergedInputs;
            inherit name;
            nixConfig = nixConfig;
            myPkgs = mkMyPkgs system;
          };
        modules =
          if bare
          then [./nixos/hosts/${name}.nix]
          else [
            nixosModule
            ./nixos/machine-types/${type}.nix
            ./nixos/roles/virtualization/multiarch.nix
            ./nixos/roles/nixos/attic.nix
            {
              heywoodlh.defaults = {
                enable = true;
                hostname = name;
                user = {
                  name = "heywoodlh";
                  description = "Spencer Heywood";
                  uid = 1000;
                  homeDir = "/home/heywoodlh";
                };
              };
              home-manager.extraSpecialArgs = inputs // {myPkgs = mkMyPkgs system;};
              home-manager.sharedModules = [homeModule];
              heywoodlh.stylix.enable = true;
            }
            ./nixos/hosts/${name}.nix
          ];
      };
    mkDarwin = name: let
      system = "aarch64-darwin";
      pkgs = mkPkgs nixpkgs system;
    in
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs =
          mergedInputs
          // {
            inputs = mergedInputs;
            inherit name;
            myPkgs = mkMyPkgs system;
          };
        modules = [
          darwinModule
          home-manager.darwinModules.home-manager
          inputs.nix-llama.darwinModules.default
          inputs.cart.darwinModules.${system}.cart
          inputs.stylix.darwinModules.stylix
          ./darwin/roles/base.nix
          ./darwin/roles/defaults.nix
          ./darwin/roles/pkgs.nix
          ./darwin/roles/network.nix
          ./darwin/hosts/${name}.nix
          {
            nix.settings = nixConfig;
            nixpkgs.overlays = [inputs.nur.overlays.default];
            heywoodlh = {
              defaults = {
                enable = true;
                user = {
                  uid = 501;
                  homeDir = "/Users/heywoodlh";
                };
              };
              darwin.lmstudio.enable = true;
            };
            home-manager = {
              useGlobalPkgs = true;
              backupCommand = "${pkgs.coreutils}/bin/rm -f";
              extraSpecialArgs =
                inputs
                // {
                  osClass = "darwin";
                  myPkgs = mkMyPkgs system;
                };
              users.heywoodlh = {...}: {
                imports = [homeModule];
                home.packages = import ./darwin/user-packages.nix {inherit pkgs;};
                heywoodlh.home = {
                  darwin.protondrive = true;
                  onepassword.enable = true;
                  llm.apfel = true;
                };
              };
            };
            networking.hostName = name;
            networking.computerName = name;
            system.stateVersion = 6;
          }
        ];
      };
    mkHome = system: name: let
      pkgs = mkPkgs nixpkgs system;
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs =
          inputs
          // {
            osClass = "nixos";
            myPkgs = mkMyPkgs system;
          };
        modules = [
          homeModule
          ./home/hosts/${name}.nix
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [inputs.nur.overlays.default];
            nix.package = pkgs.nix;
            fonts.fontconfig.enable = true;
            programs.home-manager.enable = true;
            targets.genericLinux.enable = true;
            home.backupCommand = "${pkgs.coreutils}/bin/rm -f";
            home.packages = import ./home/packages.nix {inherit pkgs name;};
          }
        ];
      };
  in {
    nixosConfigurations = lib.mapAttrs mkNixos {
      homelab = {
        system = "x86_64-linux";
        type = "server";
      };
      family.system = "x86_64-linux";
      nixos-arm64 = {
        system = "aarch64-linux";
        type = "server";
      };
      nixos-blade = {
        system = "x86_64-linux";
        type = "laptop";
      };
      nixos-console = {
        system = "x86_64-linux";
        type = "console";
      };
      nixos-culug = {
        system = "x86_64-linux";
        type = "server";
      };
      nixos-desktop.system = "x86_64-linux";
      nixos-dev = {
        system = "x86_64-linux";
        type = "vm";
      };
      nixos-framework = {
        system = "x86_64-linux";
        type = "laptop";
      };
      nixos-gaming.system = "x86_64-linux";
      nixos-gaming-sarah.system = "x86_64-linux";
      nixos-init = {
        system = "x86_64-linux";
        bare = true;
      };
      nixos-iso = {
        system = "x86_64-linux";
        bare = true;
      };
      nixos-lima = {
        system = "x86_64-linux";
        type = "lima";
      };
      nixos-m1-mac-mini.system = "aarch64-linux";
      nixos-nuc.system = "x86_64-linux";
      nixos-ops.system = "x86_64-linux";
      nixos-server = {
        system = "x86_64-linux";
        type = "server";
      };
      nixos-thinkpad = {
        system = "x86_64-linux";
        type = "laptop";
      };
      nixos-usb.system = "x86_64-linux";
      nixos-utm = {
        system = "x86_64-linux";
        type = "vm";
      };
      nixos-vmware = {
        system = "x86_64-linux";
        type = "vm";
      };
      nixos-xps = {
        system = "x86_64-linux";
        type = "laptop";
      };
      nixos-yoga = {
        system = "x86_64-linux";
        type = "laptop";
      };
      steam-deck = {
        system = "x86_64-linux";
        flake = inputs.nixpkgs-jovian-nixos;
      };
    };

    darwinConfigurations = lib.mapAttrs (name: _: mkDarwin name) {
      m1-mac-mini = {};
      m4-macbook-air = {};
      mac-mini = {};
    };

    nixosModules.heywoodlh = nixosModule;
    nixosModules.docs = {...}: {imports = myNixOSModules;};
    darwinModules.heywoodlh.darwin = darwinModule;
    homeModules.heywoodlh = {
      home = homeModule;
    };

    packages = forAllSystems (system: let
      pkgs = mkPkgs nixpkgs system;
      myPkgs = mkMyPkgs system;
      eval = pkgs.lib.evalModules {
        specialArgs =
          mergedInputs
          // {
            inherit pkgs myPkgs;
            inputs = mergedInputs;
          };
        modules = [
          darwinModule
          {config._module.check = false;}
          ({...}: {
            imports = allHomeModules;
            config._module.check = false;
          })
          ({...}: {
            imports = myNixOSModules;
            config._module.check = false;
          })
        ];
      };
      cleanEval = pkgs.lib.filterAttrsRecursive (n: _v: n != "_module") eval;
      optionsDoc = pkgs.nixosOptionsDoc {inherit (cleanEval) options;};
    in
      myPkgs
      // lib.optionalAttrs (lib.hasSuffix "linux" system) {
        homeConfigurations = lib.mapAttrs (name: _: mkHome system name) {
          heywoodlh = {};
          heywoodlh-server = {};
          heywoodlh-lima = {};
        };
      }
      // {
        inherit (myPkgs) fish tmux helix op-wrapper vim;
        tangled-sync = pkgs.callPackage ./pkgs/tangled-sync.nix {};
        spindle-run = inputs.spindle-run.packages.${system}.spindle-run;
        iso = self.nixosConfigurations.nixos-iso.config.system.build.isoImage;
        ansible-workstation = pkgs.writeShellScriptBin "ansible-workstation" ''
          export LC_ALL="C.UTF-8"
          export ANSIBLE_INJECT_FACT_VARS=True
          sudo ${pkgs.ansible}/bin/ansible-galaxy install -r ${self}/ansible/requirements.yml
          sudo ${pkgs.ansible}/bin/ansible-playbook --connection=local --extra-vars "nixos_configs_root=path:${self}" ${self}/ansible/workstation/workstation.yml
        '';
        ansible-server = pkgs.writeShellScriptBin "ansible-server" ''
          export LC_ALL="C.UTF-8"
          export ANSIBLE_INJECT_FACT_VARS=True
          sudo ${pkgs.ansible}/bin/ansible-galaxy install -r ${self}/ansible/requirements.yml
          sudo ${pkgs.ansible}/bin/ansible-playbook --connection=local --extra-vars "nixos_configs_root=path:${self}" ${self}/ansible/server/standalone.yml
        '';
        docs = pkgs.runCommand "options-doc.md" {} ''
          cat ${optionsDoc.optionsCommonMark} | ${pkgs.gnused}/bin/sed -E 's|file://||g' \
            | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/darwin\/modules|https:\/\/tangled.org\/heywoodlh.io\/nixos-configs\/blob\/main\/darwin\/modules|g' \
            | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/nixos\/modules|https:\/\/tangled.org\/heywoodlh.io\/nixos-configs\/blob\/main\/nixos\/modules|g' \
            | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/home\/modules|https:\/\/tangled.org\/heywoodlh.io\/nixos-configs\/blob\/main\/home\/modules|g' > $out
        '';
      });

    formatter = forAllSystems (system: (mkPkgs nixpkgs system).alejandra);

    devShells = forAllSystems (system: let
      pkgs = mkPkgs nixpkgs system;
      stable-pkgs = mkPkgs nixpkgs-stable system;
    in {
      default = pkgs.mkShell {
        name = "nixos-configs devShell";
        buildInputs = with pkgs; [
          lefthook
          stable-pkgs.gitleaks
          strip-ansi
          alejandra
          statix
          deadnix
          shellcheck
          actionlint
          yamllint
          self.packages.${system}.spindle-run
        ];
        shellHook = ''
          ${(pkgs.callPackage ./pkgs/tangled-sync.nix {})}/bin/tangled-sync.sh
        '';
      };
    });
  };
}
