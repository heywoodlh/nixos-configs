{ config, pkgs, lib, nur, dark-wallpaper, light-wallpaper, myFlakes, user-icon, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.workstation;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.heywoodlh.workstation = mkOption {
    default = false;
    description = "Enable heywoodlh workstation configuration.";
    type = bool;
  };

  config = let
    username = config.heywoodlh.defaults.user.name;
    userUid = config.heywoodlh.defaults.user.uid;
    homeDir = config.heywoodlh.defaults.user.homeDir;
  in mkIf cfg {
    heywoodlh.defaults = {
      enable = true;
      quietBoot = true;
    };

    services.displayManager.ly.enable = true;

    programs.dconf.enable = true;

    # Bluetooth, audio, keyring
    heywoodlh.defaults.bluetooth = true;
    heywoodlh.defaults.audio = true;
    heywoodlh.defaults.keyring = true;
    heywoodlh.defaults.user.icon = "${user-icon}";

    # Desktop environments
    heywoodlh.cosmic = true;
    heywoodlh.hyprland = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.power-profiles-daemon.enable = true;

    # enable kde connect
    programs.kdeconnect.enable = true;

    networking.firewall = {
      interfaces.tailscale0.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131;} ];
      interfaces.tailscale0.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    # Desktop packages
    environment.systemPackages = with pkgs; [
      busybox
      lsof
      gnome-screenshot
      ifuse
      usbutils
      ente-auth
      myFlakes.packages.${system}.tmux
      myFlakes.packages.${system}.helix
    ];

    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "heywoodlh" ];
    };

    # configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # printers
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true; # For wifi printers
    };
    # for scanning documents
    hardware.sane.enable = true;

    # android debugging
    programs.adb.enable = true;

    # iphone usb support
    services.usbmuxd.enable = true;

    # Allow x86 packages to be installed on aarch64
    nixpkgs.config.allowUnsupportedSystem = true;

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
    };

    fonts.packages = with pkgs.nerd-fonts; [
      jetbrains-mono
    ];

    users.extraGroups.vboxusers.members = [ "${username}" ];
    users.extraGroups.disk.members = [ "${username}" ];
    users.extraGroups.video.members = [ "${username}" ];

    users.users.${username} = {
      packages = with pkgs; [
        legcord
      ];
    };

    services = {
      logind.settings.Login.RuntimeDirectorySize = "10G";
      syncthing = {
        enable = true;
        user = "heywoodlh";
        dataDir = "${homeDir}/Sync";
        configDir = "${homeDir}/.config/syncthing";
      };
    };

    # Enable ergodox ez/moonlander keyboard tools
    hardware.keyboard.zsa.enable = true;

    # Thunderbolt 3
    services.hardware.bolt.enable = true;

    xdg.portal.enable = true;
    services.flatpak.enable = true;

    # Use seahorse ssh-agent
    system.activationScripts.symlink-ssh-agent = {
      text = ''
        mkdir -p ${homeDir}/.ssh && chown -R ${username} ${homeDir}/.ssh
        ln -s /run/user/${builtins.toString userUid}/keyring/ssh ${homeDir}/.ssh/agent.sock &> /dev/null || true
      '';
    };

    # Home-manager configs
    home-manager = {
      extraSpecialArgs = {
        inherit nur;
        inherit light-wallpaper;
        inherit dark-wallpaper;
      };
      users.${username} = { ... }: {
        imports = [
          ../../home/desktop.nix # base desktop.nix
          ../../home/linux/desktop.nix # linux-specific desktop.nix
        ];
        heywoodlh.home.gnome = mkForce config.heywoodlh.gnome;
      };
    };
  };
}
