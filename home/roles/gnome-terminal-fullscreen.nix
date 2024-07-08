{ config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  home.file.".config/autostart/gnome-terminal-fullscreen.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=GNOME Terminal fullscreen
      Exec=gnome-terminal --full-screen
      Terminal=false
      Type=Application
      Icon=${homeDir}/.icons/snowflake.png
      Categories=Utility;
    '';
  };
}
