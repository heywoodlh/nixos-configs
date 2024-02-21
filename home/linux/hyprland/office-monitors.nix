{ config, pkgs, hyprland, ... }:

{
  wayland.windowManager.hyprland.extraConfig = ''
    monitor = DP-2, disable # Disable redundant 2K display
  '';
}
