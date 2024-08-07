{ config, pkgs, snowflake, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  home.file.".local/share/applications/gnome-terminal-fullscreen.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=GNOME Terminal fullscreen
      Exec=gnome-terminal --full-screen
      Terminal=false
      Type=Application
      Icon=${snowflake}
      Categories=Utility;
    '';
  };
}
