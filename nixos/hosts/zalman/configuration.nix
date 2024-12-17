# Config specific to my Zalman gaming PC
{ config, pkgs, lib, home-manager,
  nur, hyprland, nixpkgs-backports,
  nixpkgs-stable, nixpkgs-lts,
  myFlakes, flatpaks,
  light-wallpaper, dark-wallpaper,
  snowflake,
  mullvad-browser-home-manager,
  ts-warp-nixpkgs, qutebrowser,
  ... }:

let
  system = pkgs.system;
  stable-pkgs = import nixpkgs-lts {
    inherit system;
    config.allowUnfree = true;
  };
  rustdesk = pkgs.writeShellScriptBin "rustdesk" ''
    bash -c "SHELL='/run/current-system/sw/bin/bash' ${pkgs.rustdesk-flutter}/bin/rustdesk" $@
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/gaming/nvidia-patch.nix
    ../../roles/gaming/sunshine.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixos-zalman";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.utf8";

  environment.systemPackages = with pkgs; [
    playerctl
    exfatprogs
    spotify
    protontricks
  ];

  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };

  networking.interfaces.enp4s0.wakeOnLan.enable = true;

  # filesystems
  fileSystems = {
    "/games/steam-ssd" = {
      device = "/dev/disk/by-uuid/75B216AE47BC9371";
      fsType = "ntfs-3g";
      options = [
        "uid=1000"
        "gid=1000"
        "umask=000"
        "rw"
        "user"
        "exec"
        "nofail"
        "noacsrules"
      ];
    };
    "/games/wd-black" = {
      device = "/dev/disk/by-uuid/2292D29C92D273AF";
      fsType = "ntfs-3g";
      options = [
        "uid=1000"
        "gid=1000"
        "umask=000"
        "rw"
        "user"
        "exec"
        "nofail"
        "noacsrules"
      ];
    };
  };

  swapDevices = [
    {
      device = "/swap";
      size = 32 * 1024;
    }
  ];

  services = {
    logind = {
      extraConfig = "RuntimeDirectorySize=10G";
    };
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
  };


  # home-manager
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit nixpkgs-lts;
      inherit nixpkgs-stable;
      inherit light-wallpaper;
      inherit dark-wallpaper;
      inherit snowflake;
      inherit ts-warp-nixpkgs;
      inherit qutebrowser;
    };
    users.heywoodlh = { ... }: {
      imports = [
        ../../../home/linux.nix
        ../../../home/desktop.nix # base desktop.nix
        ../../../home/linux/desktop.nix # linux-specific desktop.nix
        flatpaks.homeManagerModules.declarative-flatpak
      ];
      home.packages = [
        rustdesk
      ];
      heywoodlh.home = {
        applications = [
          {
            name = "Rustdesk";
            command = "${rustdesk}/bin/rustdesk";
          }
        ];
        autostart = [
          {
            name = "Spotify";
            command = ''
              sleep 10 # start after rustdesk
              ${pkgs.spotify}/bin/spotify
            '';
          }
          {
            name = "Rustdesk";
            command = "${rustdesk}/bin/rustdesk";
          }
        ];
      };
    };
  };

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  boot.tmp.cleanOnBoot = true;
}
