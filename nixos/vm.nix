{ config, pkgs, lib, ... }:

{
  imports = [
    ./desktop.nix
    ./roles/remote-access/sshd.nix
    ./roles/dev/gnome-guest.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Enable networking
  networking = {
    networkmanager = {
      enable = true;
      # Prefer tailscale dns
      insertNameservers = [
        "100.100.100.100"
      ];
    };
    resolvconf.extraConfig = ''
      prepend_nameservers=100.100.100.100
      search_domains=barn-banana.ts.net
    '';
    hosts = {
      "100.65.244.115" = [
        "attic"
        "attic.barn-banana.ts.net"
      ];
    };
  };

  # Ensure Tmux status bar isn't turned off
  #programs.bash.interactiveShellInit = lib.mkForce "";

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

  # Enable caffeine
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
