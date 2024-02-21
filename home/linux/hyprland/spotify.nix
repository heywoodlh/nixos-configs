{ config, pkgs, home-manager, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = [workspace special:music] ${homeDir}/.nix-profile/bin/spotify
    windowrulev2 = workspace special:music, class:^(Spotify)$
    bind = CTRL_SHIFT, m, togglespecialworkspace, music
  '';
}
