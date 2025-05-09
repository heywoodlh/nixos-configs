{ config, pkgs, home-manager, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 3389 ];
  };

  services.gnome.gnome-remote-desktop.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "heywoodlh";
  };

  environment.systemPackages = with pkgs; [
    gnome-remote-desktop
  ];

  # GNOME settings through home-manager
  home-manager.users.heywoodlh = {
    dconf.settings = {
      "org.gnome.desktop.remote-desktop.rdp" = {
        screen-share-mode = "mirror-primary";
      };
    };
  };
}
