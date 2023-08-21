{ config, pkgs, ... }:

{
  services.roundcube = {
    enable = true;
    hostName = "localhost";
    plugins = with pkgs.roundcubePlugins; [
      carddav
      contextmenu
      persistent_login
    ];
  };
}
