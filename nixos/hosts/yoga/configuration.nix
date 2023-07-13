# Config specific to Lenovo Thinkpad Yoga

{ config, pkgs, lib, spicetify, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "nix-yoga"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  ## Hardware acceleration for Intel graphics
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  home-manager.users.heywoodlh = {
    # Spotify-tui + spotify-tui
    services.spotifyd = {
      enable = true;
      settings = {
        global = {
          username = "31los4pph7awxi3i2inw5xiyut4u";
          password_cmd = "cat ~/.config/spotifyd/password.txt";
          device_name = "spotifyd";
        };
      };
    };
    home.packages = with pkgs; [
      remmina
      rustdesk
      spicetify.packages.x86_64-linux.nord
      spotify-tui
    ];
    wayland.windowManager.hyprland.extraConfig = ''
      exec-once = [workspace special:music] wezterm start -- spt
      bind = CTRL_SHIFT, m, togglespecialworkspace, music
    '';
    # spotify-tui desktop entry
    home.file.".local/share/applications/spotify-tui.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=spotify-tui
        GenericName=spotify-tui
        Comment=Spotify in terminal
        Exec=${pkgs.wezterm} start --class="Spotify-TUI" -- ${pkgs.spotify-tui}/bin/spt
        Terminal=false
        Type=Application
        Keywords=music
        Icon=nix-snowflake
        Categories=Music;
      '';
    };
  };

  # Allow PAM to use Yubikey for auth
  # Setup with these commands:
  # nix-shell -p yubico-pam -p yubikey-manager
  # pamu2fcfg -NP > ~/.config/Yubico/u2f_keys
  security.pam.u2f = {
    enable = true;
    control = "sufficient";
  };

  # Hardware config specific to Lenovo Yoga 7i
  # Arch Wiki was helpful: https://wiki.archlinux.org/title/Lenovo_Yoga_7i
  hardware.sensor.iio.enable = true;
  boot.kernelParams = [ "mem_sleep_default=s2idle" "ideapad_laptop" ];
  services.power-profiles-daemon.enable = true;

  # Set version of NixOS to target
  system.stateVersion = "23.05";
}
