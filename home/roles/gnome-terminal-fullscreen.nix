{ config, pkgs, ... }:

{
  home.files.".config/autostart/gnome-terminal-fullscreen.desktop" = {
    enable = true;
    text = ''
      gnome-terminal --full-screen
    '';
  };
}
