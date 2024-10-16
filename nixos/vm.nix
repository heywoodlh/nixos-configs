{ config, pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./desktop.nix
    ./roles/remote-access/sshd.nix
    ./roles/dev/gnome-guest.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Enable networking
  networking = {
    networkmanager.enable = true;
    hosts = {
      "100.69.64.103" = [
        "attic"
        "attic.barn-banana.ts.net"
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Disable sound
  services.pipewire = {
    enable = lib.mkForce false;
    alsa.enable = lib.mkForce false;
    alsa.support32Bit = lib.mkForce false;
    pulse.enable = lib.mkForce false;
  };

  # Disable bluetooth
  hardware.bluetooth.enable = lib.mkForce false;

  # Append ts net to SSH
  programs.ssh.extraConfig = ''
    CanonicalizeHostname yes
    CanonicalDomains barn-banana.ts.net
  '';

  home-manager.users.heywoodlh.dconf.settings = {
    "org/gnome/shell/extensions/caffeine" = {
      toggle-state = true;
      user-enabled = true;
    };
  };

  # Enable SPICE guest agent
  services.spice-vdagentd.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
}
