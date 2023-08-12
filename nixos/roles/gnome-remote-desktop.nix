{ config, pkgs, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

  networking.firewall = {
    allowedTCPPorts = [ 3389 ];
  };

  services.gnome.gnome-remote-desktop.enable = true;
  services.xserver.displayManager.autoLogin = {
    user = "heywoodlh";
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-remote-desktop
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
