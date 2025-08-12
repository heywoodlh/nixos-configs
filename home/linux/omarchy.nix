{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Guake-like terminal
      bind = CTRL, grave, togglespecialworkspace, terminal
      workspace = special:terminal, on-created-empty:${pkgs.ghostty}/bin/ghostty --font-size=12
    '';
  };
}
