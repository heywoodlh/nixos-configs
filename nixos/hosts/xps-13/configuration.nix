# Config specific to Dell XPS 13
{ config, pkgs, nixpkgs-stable, lib, spicetify, ... }:

let
  system = pkgs.system;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../laptop.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-xps"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    imports = [
      ../../../home/roles/discord.nix
    ];
    home.packages = with pkgs; [
      beeper
      rustdesk-flutter
      signal-desktop
      spicetify.packages.x86_64-linux.nord-text
      zoom-us
    ];
  };

  # Fingerprint
  services.fprintd = {
    enable = true;
    package = stable-pkgs.fprintd-tod;
    tod.enable = true;
    tod.driver = lib.mkForce stable-pkgs.libfprint-2-tod1-goodix;
  };

  # Only use fingerprint auth when lid open
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/security/pam.nix#L686C13-L686C158
  security.pam.services = let
    check-lid = pkgs.writeShellScript "lid.sh" ''
      #https://unix.stackexchange.com/a/743941
      ${pkgs.gnugrep}/bin/grep -q closed /proc/acpi/button/lid/LID0/state && exit 1; true
    '';
    limitsConf = pkgs.writeText "limits.conf" ''
      @pipewire - rtprio 95
      @pipewire - nice -19
      @pipewire - memlock 4194304
    '';
    fprintConfig = ''
       # Account management.
      account required ${pkgs.linux-pam}/lib/security/pam_unix.so # unix (order 10900)

      # Authentication management.
      # Skip fingerprint if lid closed
      auth   [success=ignore default=1]  pam_exec.so quiet ${check-lid}
      auth sufficient ${stable-pkgs.fprintd-tod}/lib/security/pam_fprintd.so # fprintd (order 11300)
      auth sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so likeauth try_first_pass # unix (order 11500)
      auth required ${pkgs.linux-pam}/lib/security/pam_deny.so # deny (order 12300)
      # Password management.
      password sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so nullok yescrypt # unix (order 10200)

      # Session management.
      session required ${pkgs.linux-pam}/lib/security/pam_env.so conffile=/etc/pam/environment readenv=0 # env (order 10100)
      session required ${pkgs.linux-pam}/lib/security/pam_unix.so # unix (order 10200)
      session required ${pkgs.linux-pam}/lib/security/pam_limits.so conf=${limitsConf} # limits (order 12200)
    '';
  in {
    sudo.text = lib.mkForce fprintConfig;
    polkit-1.text = lib.mkForce fprintConfig;
  };

  # Hard limits for Nix
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };

  services.fwupd.enable = true;

  # Set version of NixOS to target
  system.stateVersion = "24.05";
}
