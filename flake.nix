rec {
  description = "heywoodlh nix config";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixos-unstable"; # Separate input for overriding
    nixpkgs-stable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1";
    nixpkgs-nvidia.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    nixpkgs-sunshine.url = "github:Qubasa/nixpkgs/update_sunshine";
    nixpkgs-backports.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs-pam-lid-fix.url = "github:heywoodlh/nixpkgs/lid-close-fprint-disable";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
      inputs.nur.follows = "nur";
      inputs.flake-parts.follows = "flake-parts";
    };
    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    # only to sync dependents that use flake-utils
    flake-utils.url = "github:numtide/flake-utils";
    # only to sync dependents that use flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "devenv/flake-compat";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit.follows = "pre-commit-hooks";
      inputs.crane.follows = "crane";
    };
    # For dependents of treefmt-nix
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For Steam on Apple Silicon
    vidhanix = {
      url = "github:vidhanio/vidhanix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-lib.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        home-manager.follows = "home-manager";
        hyprland.follows = "hyprland";
        nixos-apple-silicon.follows = "nixos-apple-silicon";
        stylix.follows = "stylix";
        systems.follows = "flake-utils/systems";
        treefmt-nix.follows = "treefmt-nix";
        git-hooks-nix.follows = "pre-commit-hooks";
        agenix.follows = "";
        disko.follows = "";
        vidhan-fonts.follows = "";
        vscode-extensions.follows = "";
        spicetify-nix.follows = "";
        ghostty-shader-playground.follows = "";
        nixvim.follows = "";
        impermanence.follows = "";
        nixcord.follows = "";
        nix-index-database.follows = "";
        nix-cachyos-kernel.follows = "";
      };
    };
    # only to sync dependents that use nix
    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "nixos-apple-silicon/flake-compat";
      inputs.git-hooks-nix.follows = "pre-commit-hooks";
    };
    # for dependents of crane
    crane.url = "github:ipetkov/crane";
    # for dependents of helix-src
    helix-src = {
      url = "github:heywoodlh/helix/issue-2719";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "lanzaboote/rust-overlay";
    };
    fish-flake = {
      url = ./flakes/fish;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    helix-flake = {
      url = ./flakes/helix;
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.helix-src.follows = "helix-src";
    };
    vim-flake = {
      url = ./flakes/vim;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    chromium-widevine-flake = {
      url = ./flakes/chromium-widevine;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae-nix = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };
    gnome-flake = {
      url = ./flakes/gnome;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.fish-flake.follows = "fish-flake";
      inputs.vim-flake.follows = "vim-flake";
      inputs.vicinae-nix.follows = "vicinae-nix";
    };
    git-flake = {
      url = ./flakes/git;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    vscode-flake = {
      url = ./flakes/vscode;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.fish-flake.follows = "fish-flake";
    };
    nushell-flake = {
      url = ./flakes/nushell;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    op-flake = {
      url = ./flakes/1password;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    ttyd-flake = {
      url = ./flakes/ttyd-nerd;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    myFlakes = {
      url = ./flakes;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.helix-src.follows = "helix-src";
      inputs.fish-flake.follows = "fish-flake";
      inputs.helix-flake.follows = "helix-flake";
      inputs.vim-flake.follows = "vim-flake";
      inputs.chromium-widevine-flake.follows = "chromium-widevine-flake";
      inputs.gnome-flake.follows = "gnome-flake";
      inputs.vicinae-nix.follows = "vicinae-nix";
      inputs.git-flake.follows = "git-flake";
      inputs.vscode-flake.follows = "vscode-flake";
      inputs.nushell-flake.follows = "nushell-flake";
      inputs.op-flake.follows = "op-flake";
      inputs.ttyd-flake.follows = "ttyd-flake";
    };
    # for dependents of ashell
    ashell = {
      url = "github:kylesferrazza/ashell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "lanzaboote/rust-overlay";
    };
    # for dependents of devenv
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nix.follows = "nix";
      inputs.git-hooks.follows = "pre-commit-hooks";
      inputs.nixd.follows = "";
    };
    kyle = {
      url = "gitlab:kylesferrazza/nix-configs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.ashell.follows = "ashell";
      inputs.home-manager.follows = "home-manager";
      inputs.nur.follows = "nur";
      inputs.nixos-apple-silicon.follows = "nixos-apple-silicon";
      inputs.teslamate-src.follows = "";
      inputs.opnix.follows = "";
      inputs.stylix.follows = "";
      inputs.doom-d.follows = "";
      inputs.vscode-server.follows = "";
      inputs.hermes-agent.follows = "";
    };
    darwin = {
      url = "github:heywoodlh/nix-darwin/heywoodlh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.flake-compat.follows = "nixos-apple-silicon/flake-compat";
    };
    user-icon = {
      url = "https://avatar.tangled.sh/1c796c57a7536e989ab09026df5f0fe7870be6217bc8ae642e48fa449de72f59/did:plc:ycnss4fntzi3rjuueb7loq3x?v=bafkreic";
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
    # jovian-nixos requires a specific nixpkgs for its custom packages (mesa, pipewire, etc.)
    nixpkgs-jovian-nixos.url = "github:NixOS/nixpkgs/331800de5053fcebacf6813adb5db9c9dca22a0c";
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-jovian-nixos";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
      inputs.nix-darwin.follows = "darwin";
      inputs.flake-utils.follows = "flake-utils";
    };
    hexstrike-ai = {
      url = "github:heywoodlh/hexstrike-ai/nix-flake-init";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    # only to sync dependents that use pyproject-nix
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # only to sync dependents that use uv2nix
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    # only to sync dependents that use pre-commit-hooks
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "nixos-apple-silicon/flake-compat";
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
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "devenv/flake-compat";
    };
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    tangled = {
      url = "git+https://tangled.org/tangled.org/core";
       inputs.nixpkgs.follows = "nixpkgs";
       inputs.flake-compat.follows = "devenv/flake-compat";
       inputs.gomod2nix.follows = "gomod2nix";
     };
    spindle-run = {
      url = "git+https://tangled.org/heywoodlh.io/spindle-run";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.tangled.follows = "tangled";
    };
    stackpkgs = {
      url = "git+https://code.thishorsie.rocks/ryze/stackpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    gh-gitignore = {
      url = "github:github/gitignore";
      flake = false;
    };
    opencode-ssh = {
      url = "github:snez/opencode-ssh";
      flake = false;
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

  outputs = inputs@{ self,
                      nixpkgs,
                      nixpkgs-stable,
                      nixpkgs-nvidia,
                      nixpkgs-sunshine,
                      nixpkgs-pam-lid-fix,
                      myFlakes,
                      stylix,
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
                      cart,
                      hexstrike-ai,
                      hyprland,
                      nix-on-droid,
                      vidhanix,
                      lanzaboote,
                      nix-cachyos-kernel,
                      spindle-run,
                      stackpkgs,
                      helium,
                      nixpkgs-jovian-nixos,
                      nixos-lima,
                      gh-gitignore,
                      opencode-ssh,
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
    darwinSystem = "${arch}-darwin";
    # Modules for NixOS and Nix-Darwin
    commonModules = [
      ./base/stylix.nix
    ];
    darwinModules.heywoodlh.darwin = { config, pkgs, ... }: {
      imports = [
        ./darwin/modules/defaults.nix
        ./darwin/modules/sketchybar.nix
        ./darwin/modules/yabai.nix
        ./darwin/modules/stage-manager.nix
        ./darwin/modules/choose-launcher.nix
        ./darwin/modules/raycast.nix
        ./darwin/modules/stylix.nix
        ./darwin/modules/lmstudio.nix
      ] ++ commonModules;
    };
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
    ];
    linuxHomeModules = [
      ./home/modules/gnome.nix
      ./home/modules/cosmic.nix
      ./home/modules/guake.nix
      ./home/modules/hyprland.nix
      ./home/modules/vicinae.nix
      ./home/modules/linux-autostart.nix
      ./home/modules/onepassword.nix
      ./home/modules/bluetuith.nix
      ./home/modules/moonlight.nix
      ./home/modules/kde-windows.nix
    ];
    macosHomeModules = [
      ./home/modules/darwin-defaults.nix
      ./home/modules/disable-spotlight.nix
      ./home/modules/nord-terminal.nix
      ./home/modules/darwin-protondrive-link.nix
    ];
    myHomeModules = commonHomeModules ++ linuxHomeModules ++ macosHomeModules;
    # Combine all modules, excluding modules not relevant to platform
    platformHomeModules = if pkgs.stdenv.isDarwin then
      commonHomeModules ++ macosHomeModules
    else
      commonHomeModules ++ linuxHomeModules
    ;
    homeModules.heywoodlh.home = { config, pkgs, ... }: {
      imports = platformHomeModules;
    };
    # For docs only (to enumerate _all_ home modules regardless of platform)
    homeModules.docs = { config, pkgs, ... }: {
      imports = myHomeModules;
    };
    extNixOSModules = [
      home-manager.nixosModules.home-manager
      stylix.nixosModules.stylix
      kyle.nixosModules.apple-silicon-support
      kyle.nixosModules.appleSilicon
      jovian-nixos.nixosModules.default
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
      ./nixos/modules/helix.nix
      ./nixos/modules/luks.nix
      ./nixos/modules/backups.nix
      ./nixos/modules/cloudflared.nix
      ./nixos/modules/rayhunter.nix
      ./nixos/modules/stylix.nix
      ./nixos/modules/sunshine.nix
      ./nixos/modules/nvidia-patch.nix
      ./nixos/modules/gaming.nix
      ./nixos/modules/cachyos-kernel.nix
      ./nixos/modules/steam-deck.nix
      ./nixos/modules/vmware-workstation.nix
      ./nixos/modules/scrutiny.nix
      ./nixos/modules/kde.nix
      ./nixos/modules/tor.nix
      ./nixos/modules/libvirtd.nix
    ] ++ commonModules;
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
        home-manager.darwinModules.home-manager
        cart.darwinModules.${system}.cart
        stylix.darwinModules.stylix
        ./darwin/roles/base.nix
        ./darwin/roles/defaults.nix
        ./darwin/roles/pkgs.nix
        ./darwin/roles/network.nix
        extraConf
        {
          nix.settings = nixConfig;
          # Import nur as nixpkgs.overlays
          nixpkgs.overlays = [
            nur.overlays.default
          ];

          heywoodlh = {
            darwin = {
              defaults.enable = true;
              lmstudio.enable = true;
            };
          };

          home-manager = {
            useGlobalPkgs = true;
            extraSpecialArgs = inputs;
            users.heywoodlh = { ... }: {
              imports = [
                homeModules.heywoodlh.home
              ];
              home.packages = let
                nixos-switch = pkgs.writeShellScriptBin "nixos-switch" ''
                  #limactl shell nixos sudo nixos-rebuild boot --accept-flake-config --flake $HOME/opt/nixos-configs#nixos-lima --impure $@ && echo "Rebooting VM..." && limactl shell nixos sudo shutdown -r now
                  limactl shell nixos nix run "github:nix-community/home-manager" -- switch --flake $HOME/opt/nixos-configs#heywoodlh-lima
                '';
                nixos-build = pkgs.writeShellScriptBin "nixos-build" ''
                  attic-setup
                  limactl shell nixos mkdir -p /home/heywoodlh.guest/.config/attic
                  scp -F $HOME/.lima/nixos/ssh.config $HOME/.config/attic/config.toml lima-nixos:/home/heywoodlh.guest/.config/attic/attic.toml
                  # Desktop
                  ${pkgs.lima}/bin/limactl shell nixos nixos-rebuild build --accept-flake-config --flake $HOME/opt/nixos-configs#nixos-desktop
                  ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
                  # Server
                  ${pkgs.lima}/bin/limactl shell nixos nixos-rebuild build --accept-flake-config --flake $HOME/opt/nixos-configs#nixos-server
                  ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
                  # Asahi
                  ## Kernel
                  ${pkgs.lima}/bin/limactl shell nixos nix build --accept-flake-config $HOME/opt/nixos-configs#nixosConfigurations.nixos-m1-mac-mini.config.boot.kernelPackages.kernel
                  ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
                  ## Mesa
                  ${pkgs.lima}/bin/limactl shell nixos nix build --accept-flake-config $HOME/opt/nixos-configs#nixosConfigurations.nixos-m1-mac-mini.config.hardware.opengl.package
                  ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
                '';
              in [
                nixos-build
                nixos-switch
              ];
              heywoodlh.home = {
                darwin.protondrive = true;
              };
            };
          };

          networking.hostName = myHostname;
          networking.computerName = myHostname;
          system.stateVersion = 6;
        }
      ];
    };

    nixosConfigWith = nixpkgsPkgs: machineType: myHostname: extraConf: nixpkgsPkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // { inherit inputs; };
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
          home-manager.extraSpecialArgs = inputs;
          home-manager.users.heywoodlh = { ... }: {
            imports = [
              homeModules.heywoodlh.home
            ];
          };
          home-manager.users.root = { ... }: {
            imports = [
              homeModules.heywoodlh.home
            ];
          };
          heywoodlh.stylix.enable = true;
        }
        extraConf
      ] ++ lib.optionals (machineType == "server") [
        ./nixos/roles/security/sshd-monitor.nix
        ./nixos/roles/tailscale.nix
        ./nixos/roles/monitoring/syslog-ng/client.nix
        ./nixos/roles/monitoring/node-exporter.nix
        {
          heywoodlh.server = true;
          heywoodlh.nixos.scrutiny = {
            enable = true;
            port = 3050;
            ntfy = "ntfy://ntfy.barn-banana.ts.net/monitoring";
          };
          nix.settings = {
            auto-optimise-store = true;
          } // nixConfig;
        }
      ] ++ lib.optionals (machineType == "workstation") [
        ./nixos/roles/hardware/printers.nix
        { heywoodlh.workstation = true; }
      ] ++ lib.optionals (machineType == "laptop") [
        { heywoodlh.laptop = true; }
      ] ++ lib.optionals (machineType == "vm") [
        { heywoodlh.vm = true; }
      ] ++ lib.optionals (machineType == "lima") [
        nixos-lima.nixosModules.lima
        (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        {
          heywoodlh = {
            sshd.enable = true;
            defaults = {
              enable = true;
              # Disable services that should be on host
              tailscale = false;
              syncthing = false;
            };
          };

          # Lima configuration from https://github.com/nixos-lima/nixos-lima/blob/master/lima.nix
          services.lima.enable = true;
          security = {
            sudo.wheelNeedsPassword = false;
          };
          boot.loader = {
            systemd-boot.enable = lib.mkForce false;
            efi.canTouchEfiVariables = lib.mkForce false;
            grub = {
              device = "nodev";
              efiSupport = true;
              efiInstallAsRemovable = true;
            };
          };
          fileSystems."/boot" = {
            device = lib.mkForce "/dev/vda1";
            fsType = "vfat";
          };
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            autoResize = true;
            fsType = "ext4";
            options = [ "noatime" "nodiratime" "discard" ];
          };
        }
      ] ++ lib.optionals (machineType == "console") [
        { heywoodlh.console = true; }
      ];
    };
    nixosConfig = nixosConfigWith nixpkgs;

    eval = pkgs.lib.evalModules {
      specialArgs = { inherit pkgs; inherit myFlakes; inherit self; };
      modules = [
        darwinModules.heywoodlh.darwin { config._module.check = false; }
        homeModules.docs { config._module.check = false; }
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
    };

    # Base home configuration
    homeConfig = target: user: homeDir: extraConf: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = inputs;
      modules = [
        homeModules.heywoodlh.home
        ./home/linux.nix
        {
          home = {
            username = "${user}";
            homeDirectory = "${homeDir}";
          };
          nixpkgs.config.permittedInsecurePackages = [
            "olm-3.2.16"
          ];
          # Home-Manager specific nixpkgs config
          nixpkgs.config = {
            allowUnfree = true;
            # Allow olm for gomuks until issues are resolved
            overlays = [
              nur.overlays.default
            ];
          };
          nix.package = pkgs.nix;
          fonts.fontconfig.enable = true;
          programs.home-manager.enable = true;
          targets.genericLinux.enable = true;

          home.packages = let
            homeSwitch = pkgs.writeShellScriptBin "home-switch" ''
              if [[ -d $HOME/opt/nixos-configs ]]
              then
                target="$HOME/opt/nixos-configs"
              else
                target="git+https://tangled.org/heywoodlh.io/nixos-configs"
              fi
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
                ## Support for Ubuntu 24-25, TODO support 25 standalone after May 2025
                if echo "$version" | ${pkgs.gnugrep}/bin/grep -q '26'
                then
                  EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-26.05"
                fi
              fi
              ${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' run "$target#homeConfigurations.${target}.activationPackage" $EXTRA_ARGS --impure $@
            '';
          in [
            homeSwitch
          ];
        }
        extraConf
      ];
    };
    in {
      formatter = pkgs.alejandra;
      # custom nix-darwin modules
      darwinModules.heywoodlh = darwinModules.heywoodlh.darwin;

      # custom nixos modules
      nixosModules.heywoodlh = nixosModules.heywoodlh;

      # custom home-manager modules
      homeModules.heywoodlh = homeModules.heywoodlh.home;

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
              home-manager.users.heywoodlh = {
                heywoodlh.home.lima.nixos.memory = 12;
              };
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
              home-manager.users.heywoodlh = {
                heywoodlh.home.lima.nixos.memory = 12;
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
            #./nixos/hosts/intel-mac-mini.nix
            /etc/nixos/hardware-configuration.nix
          ];
          swapDevices = [
            {
              device = "/swap";
              size = 8 * 1024;
            }
          ];
          # Ensure to power on in case of power failure
          system.activationScripts.rebootPowerFailure.text = ''
            ${pkgs.pciutils}/bin/setpci -s 00:1f.0 0xa4.b=0
          '';

          environment.systemPackages = with pkgs; [
            plex-htpc
            moonlight-qt
          ];

          heywoodlh = {
            nixos.steam-deck.enable = true;
            intel-mac = true;
            sshd.enable = true;
          };
        };

        nixos-slc = nixosConfig "server" "nixos-slc" {
          imports = [
            ./nixos/hosts/slc.nix
          ];
        };

        nixos-thinkpad = nixosConfig "laptop" "nixos-thinkpad" {
          imports = [
            /etc/nixos/hardware-configuration.nix
          ];
        };

        nixos-framework = nixosConfig "laptop" "nixos-framework" {
          imports = [
            nixos-hardware.nixosModules.framework-intel-core-ultra-series1
            ./nixos/hosts/framework-13.nix
          ];

          heywoodlh.nixos = {
            gaming.enable = true;
            vmware-workstation = true;
            cachyos-kernel.enable = true;
            libvirtd.enable = true;
          };

          home-manager.users.heywoodlh = {
            heywoodlh.home.llm.homelab = false;
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
            home.packages = with pkgs; [
              moonlight-qt
            ];
          };
        };

        nixos-arm64 = nixosConfig "server" "nixos-arm64" {
          imports = [
            ./nixos/hosts/nixos-arm64.nix
          ];
        };

        nixos-culug = nixosConfig "server" "nixos-culug" {
          imports = [
            ./nixos/hosts/culug.nix
          ];

          users.users.alex = {
            isNormalUser = true;
            description = "alex";
            extraGroups = [
              "wheel"
              "adbusers"
              "networkmanager"
              "docker"
            ];
            shell = pkgs.bashInteractive;
            homeMode = "755";
            packages = [
              home-manager.packages.${system}.home-manager
            ];
          };

          users.users.heywoodlh.extraGroups = [
            "docker"
          ];

          # Fix display
          boot.kernelParams = [
            "fbcon=rotate:1"
            "video=DSI-1:panel_orientation=right_side_up"
          ];

          environment.etc."nixos/README.md".text = ''
            Deploy like so:

            ```
            sudo nixos-rebuild switch --flake "git+https://tangled.org/heywoodlh.io/nixos-configs#nixos-culug"
            ```
            Open a PR if you want updates.

            CULUG services should be defined outside of NixOS with `docker`/`docker-compose` in `/opt/`. Anything that should be publicly exposed should go through Cloudflare Zero Trust.
          '';
        };

        # steam-deck uses Jovian's pinned nixpkgs as the primary nixpkgs so its
        # custom packages (mesa, pipewire, etc.) have their version requirements met.
        steam-deck = nixosConfigWith nixpkgs-jovian-nixos "workstation" "steam-deck" {
          imports = [
            ./nixos/hosts/steam-deck.nix
          ];
        };

        nixos-gaming =  nixosConfig "workstation" "nixos-gaming" {
          imports = [
            ./nixos/hosts/gaming.nix
          ];
        };

        nixos-gaming-sarah =  nixosConfig "workstation" "nixos-gaming-sarah" {
          imports = [
            ./nixos/hosts/gaming-sarah.nix
          ];
        };

        nixos-blade = nixosConfig "laptop" "nixos-blade" {
          imports = [
            ./nixos/hosts/razer-blade-14.nix
          ];
          hardware.openrazer = {
            enable = true;
            users = [
              "heywoodlh"
            ];
          };

          heywoodlh.nixos = {
            nvidia-patch = true;
            gaming.enable = true;
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
        };
        nixos-m1-mac-mini = nixosConfig "workstation" "nixos-m1-mac-mini" {
          imports = [
            ./nixos/hosts/m1-mac-mini.nix
          ];
          heywoodlh = {
            sshd.enable = true;
            nixos.gaming.enable = false;
            apple-silicon = {
              enable = true;
              cachefile = "kernelcache.release.mac13g";
              hash = {
                # Retrieve with `nix hash convert --hash-algo sha256 $(nix-prefetch-url file:///boot/asahi/kernelcache.release.mac13g)`
                cache = "sha256-SYR/EaaIDjeGfvhfzlTqgOihXNQQdBgqJbBJbq+wC9g=";
                # Retrieve with `nix hash convert --hash-algo sha256 $(nix-prefetch-url file:///boot/asahi/all_firmware.tar.gz)`
                firmware = "sha256-fJf6nF3bCevhURf45wt0NfqxLfBhrcO50lck/l6uE4o=";
              };
            };
          };
          # Bootloader
          boot.loader.efi.canTouchEfiVariables = pkgs.lib.mkForce false;

          # Apple Magic keyboard (makes useless globe key ctrl)
          boot.kernelParams = [ "hid_apple.swap_fn_leftctrl=1" ];

          fileSystems."/mnt/m1-mac-mini" = {
            device = "/dev/disk/by-uuid/6968-012B";
            fsType = "exfat";
            options = [ "rw" "uid=1000" "nofail" ];
          };

          home-manager.users.heywoodlh = {
            heywoodlh.home.moonlight = true;

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
            ./nixos/hosts/usb.nix
          ];
          boot.loader.efi.canTouchEfiVariables = pkgs.lib.mkForce false;

          # Enable KDE for interoperability amongst machines
          heywoodlh = {
            sshd = {
              enable = true;
              tailscale = true;
            };
            nixos.tor.enable = true;
          };
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
              services.openssh.enable = true;
              users.users = let
                sshKeys = ssh-keys.outPath;
              in {
                heywoodlh.openssh.authorizedKeys.keyFiles = [ sshKeys ];
                root.openssh.authorizedKeys.keyFiles = [ sshKeys ];
              };

              programs.neovim = {
                enable = true;
                vimAlias = true;
                viAlias = true;
              };
              environment.systemPackages = with pkgs; [
                git
                helix
                msedit
                nano
              ];
              services.tailscale.enable = true;
              services.syncthing = {
                enable = true;
                user = "heywoodlh";
                dataDir = "/home/heywoodlh/Sync";
                configDir = "/home/heywoodlh/.config/syncthing";
              };
            }
          ];
        };

        nixos-iso = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            ./nixos/roles/nixos/attic.nix
            {
              programs.neovim = {
                enable = true;
                vimAlias = true;
                viAlias = true;
              };
              environment.systemPackages = with pkgs; [
                git
                helix
                msedit
                nano
                e2fsprogs
              ];
              services.tailscale.enable = true;
              services.openssh.enable = true;
              users.users.nixos.openssh.authorizedKeys.keyFiles = [ ssh-keys ];
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
          ];
        };

        # VMWare VM for running on workstations
        nixos-vmware = nixosConfig "vm" "nixos-vmware" {
          imports = [
            /etc/nixos/hardware-configuration.nix
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
            /etc/nixos/hardware-configuration.nix
            (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
          ];
          services.qemuGuest.enable = true;
        };

        # Lima NixOS VM
        nixos-lima = nixosConfig "lima" "nixos-lima" {};
      };
      # home-manager targets (non NixOS/MacOS, ideally Arch Linux)
      packages.homeConfigurations = {
        heywoodlh = homeConfig "heywoodlh" "heywoodlh" "/home/heywoodlh" {
          imports = [
            ./home/desktop.nix # Base desktop config
            ./home/linux/desktop.nix # Linux-specific desktop config
          ];
          heywoodlh.home.onepassword.enable = true;
          heywoodlh.home.gnome = true;
          home.packages = [
            pkgs.nerd-fonts.jetbrains-mono
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
        };

        heywoodlh-server = homeConfig "heywoodlh-server" "heywoodlh" "/home/heywoodlh" {
          imports = [
            ./home/linux/no-desktop.nix
          ];
        };

        heywoodlh-lima = homeConfig "heywoodlh-lima" "heywoodlh" "/home/heywoodlh.guest" {
          imports = [
            ./home/linux/no-desktop.nix
          ];
          programs.bash = {
            enable = true;
            initExtra = ''
              [ -z $TMUX ] && { ${self.packages.${system}.tmux}/bin/tmux new-session -A -s main && exit;}
            '';
          };

          home.file.".config/fish/config.fish".text = let
            starship_config = pkgs.writeText "starship.toml" ''
              [character]
              success_symbol = ' [❯](bold white)'
              error_symbol = ' [❯](bold red)'

              [container]
              disabled = true
            '';
          in ''
            # Custom Starship prompt to remind me I'm in a VM
            set -gx STARSHIP_CONFIG "${starship_config}"
            ${pkgs.starship}/bin/starship init fish | source
          '';
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
          cat ${optionsDoc.optionsCommonMark} | ${pkgs.gnused}/bin/sed -E 's|file://||g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/darwin\/modules|https:\/\/tangled.org\/heywoodlh.io\/nixos-configs\/blob\/main\/darwin\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/nixos\/modules|https:\/\/tangled.org\/heywoodlh.io\/nixos-configs\/blob\/main\/nixos\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/home\/modules|https:\/\/tangled.org\/heywoodlh.io\/nixos-configs\/blob\/main\/home\/modules|g' > $out
        '';
        # Applications I want to export and remain consistent with this repo
        helix = myFlakes.packages.${system}.helix;
        fish = myFlakes.packages.${system}.fish;
        tmux = myFlakes.packages.${system}.tmux;
        op-wrapper = myFlakes.packages.${system}.op-wrapper;
        tangled-sync = pkgs.callPackage ./pkgs/tangled-sync.nix {};
        spindle-run = spindle-run.packages.${system}.spindle-run;
        # iso package is only buildable on Linux
        iso = self.packages.${system}.nixosConfigurations.nixos-iso.config.system.build.isoImage;
      };

      devShell = pkgs.mkShell {
        name = "nixos-configs devShell";
        buildInputs = with pkgs; [
          lefthook
          stable-pkgs.gitleaks # bug in pkgs.gitleaks currently
          pkgs.strip-ansi
          self.packages.${system}.spindle-run
        ];
        shellHook = ''
          ${(pkgs.callPackage ./pkgs/tangled-sync.nix {})}/bin/tangled-sync.sh
        '';
      };

    }
  );
}
