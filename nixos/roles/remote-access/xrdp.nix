{ config, pkgs, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

  services.xrdp = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 3389 ];
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-session # For XRDP+GNOME
  ];

  # GNOME settings through home-manager
  home-manager.users.heywoodlh = {
    ## Create startwm.sh for XRDP
    home.file."startwm.sh".text = ''
      #!/usr/bin/env bash
      export DESKTOP_SESSION="gnome"
      export GDMSESSION="gnome"
      export XDG_CURRENT_DESKTOP="GNOME"
      export XDG_SESSION_DESKTOP="gnome"
      dbus-run-session -- gnome-shell
    '';
    home.file."startwm.sh".executable = true;
  };
}
