{ config, pkgs, lib, determinate, nixpkgs-stable, myFlakes, home-manager, nixpkgs-lts, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.defaults;
  system = pkgs.stdenv.hostPlatform.system;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  myVim = myFlakes.packages.${system}.vim;
  myHelix = myFlakes.packages.${system}.helix-wrapper;
  myGit = myFlakes.packages.${system}.git;
  userType = submodule {
    options = {
      name = mkOption {
        default = "heywoodlh";
        type = str;
      };
      description = mkOption {
        default = "Spencer Heywood";
        type = str;
      };
      uid = mkOption {
        default = 1000;
        type = int;
      };
      homeDir = mkOption {
        default = "/home/heywoodlh";
        type = path;
      };
    };
  };
in {
  options.heywoodlh.defaults = {
    enable = mkOption {
      default = false;
      type = bool;
    };
    quietBoot = mkOption {
      default = false;
      type = bool;
    };
    hostname = mkOption {
      default = "nixos";
      type = str;
    };
    networkmanager = mkOption {
      default = true;
      type = bool;
    };
    syncthing = mkOption {
      default = true;
      type = bool;
    };
    tailscale = mkOption {
      default = true;
      type = bool;
    };
    timezone = mkOption {
      default = "America/Denver";
      type = str;
    };
    user = mkOption {
      type = userType;
    };
  };

  config = let
    hostname = cfg.hostname;
    username = cfg.user.name;
    userDesc = cfg.user.description;
    userUid = cfg.user.uid;
    homeDir = cfg.user.homeDir;
  in mkIf cfg.enable {

    networking.hostName = hostname;

    # Allow olm for gomuks until issues are resolved
    nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [
      "olm"
    ];

    boot = {
      tmp.cleanOnBoot = true;
      supportedFilesystems = [ "ntfs" "exfat" ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    } // optionalAttrs (cfg.quietBoot) {
      kernelParams = [ "quiet" "splash" ];
      plymouth.enable = true;
      consoleLogLevel = 0;
      initrd.verbose = false;
    };

    # Set your time zone.
    time.timeZone = "${cfg.timezone}";

    # Networking
    networking = {
      networkmanager.enable = cfg.networkmanager;
    };

    nix = {
      package = lib.mkForce determinate.packages.${system}.default;
      extraOptions = ''
        extra-experimental-features = nix-command flakes pipe-operators
      '';
      settings = {
        auto-optimise-store = true;
        trusted-users = [
          "${username}"
        ];
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://heywoodlh-helix.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "heywoodlh-helix.cachix.org-1:qHDV95nI/wX9pidAukzMzgeok1415rgjMAXinDsbb7M="
        ];
      };
    };

    environment.shells = [
      pkgs.bashInteractive
    ];

    environment.homeBinInPath = true;

    # virtualization
    virtualisation = {
      docker.rootless = {
        package = stable-pkgs.docker;
        enable = true;
        setSocketVariable = true;
      };
    };


    # Stable, system-wide packages
    environment.systemPackages = with stable-pkgs; let
      nixPkg = determinate.packages.${system}.default;
      nixosRebuildWrapper = pkgs.writeShellScript "nixos-rebuild-wrapper" ''
        [[ -d $HOME/opt/nixos-configs ]] || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /home/heywoodlh/opt/nixos-configs
        # Wrapper to use the stable nixos-rebuild
        sudo ${nixPkg}/bin/nix run "github:nixos/nixpkgs/nixpkgs-unstable#nixos-rebuild-ng" -- $1 --flake /home/heywoodlh/opt/nixos-configs#$(hostname) ''${@:2}
      '';
      myNixosSwitch = pkgs.writeShellScriptBin "nixos-switch" ''
        ${nixosRebuildWrapper} switch $@
      '';
      myNixosBoot = pkgs.writeShellScriptBin "nixos-boot" ''
        ${nixosRebuildWrapper} boot $@
      '';
      myNixosBuild = pkgs.writeShellScriptBin "nixos-build" ''
        ${nixosRebuildWrapper} build $@
      '';
      myNixosSwitchWithFlakes = pkgs.writeShellScriptBin "nixos-switch-with-flakes" ''
        ${myNixosSwitch}/bin/nixos-switch --override-input myFlakes /home/heywoodlh/opt/flakes $@
      '';
    in [
      gptfdisk
      myNixosSwitch
      myNixosSwitchWithFlakes
      myNixosBoot
      myNixosBuild
      myGit
      myHelix
      myVim
      mosh
      ntfs3g
      exfatprogs
    ];

    # Enable appimage
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    # Allow non-free applications to be installed
    nixpkgs.config.allowUnfree = true;


    i18n.defaultLocale = "en_US.UTF-8";

    # Enable gnupg agent
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    programs.nix-index.enable = true;
    programs.command-not-found.enable = false;

    # Automatically garbage collect
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    services = {
      tailscale = {
        enable = cfg.tailscale;
        extraSetFlags = [
          "--accept-routes"
        ];
      };
    } // optionalAttrs (cfg.syncthing) {
        logind.settings.Login.RuntimeDirectorySize = "10G";
        syncthing = {
          enable = cfg.syncthing;
          user = "${username}";
          dataDir = "${homeDir}/Sync";
          configDir = "${homeDir}/.config/syncthing";
        };
    };

    users.users.${username} = {
      isNormalUser = true;
      description = "${userDesc}";
      extraGroups = [
        "wheel"
        "adbusers"
      ] ++ optionals (cfg.networkmanager) [
        "networkmanager"
      ];
      shell = pkgs.bashInteractive;
      homeMode = "755";
    };

    # Home-manager configs
    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit determinate;
        inherit myFlakes;
        inherit nixpkgs-stable;
        inherit nixpkgs-lts;
      };
      backupFileExtension = ".bak";
      users.${username} = { ... }: {
        home.activation.docker-rootless-context = ''
          if ! ${pkgs.docker-client}/bin/docker context ls | grep -iq rootless
          then
            ${pkgs.docker-client}/bin/docker context create rootless --docker "host=unix:///run/user/1000/docker.sock" &> /dev/null || true
            ${pkgs.docker-client}/bin/docker context use rootless
          fi
        '';
        imports = [
          ../../home/linux.nix
        ];
        home.packages = [
          myFlakes.packages.${system}.git
        ];
      };
    };

    # NixOS version
    system.stateVersion = "25.05";
  };
}
