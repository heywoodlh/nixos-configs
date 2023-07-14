{ config, pkgs, lib, home-manager, hyprland, ... }:
{
  home.packages = with pkgs; [
    spotify-tui
  ];
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = [workspace special:music] ${pkgs.wezterm}/bin/wezterm start -- ${pkgs.spotify-tui}/bin/spt
    windowrulev2 = workspace special:music, class:^(Spotify-TUI)$
    bind = CTRL_SHIFT, m, togglespecialworkspace, music
  '';
  # Spotify-tui + spotify-tui
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "31los4pph7awxi3i2inw5xiyut4u";
        password_cmd = "cat /home/heywoodlh/.config/spotifyd/password.txt";
        device_name = "spotifyd";
      };
    };
  };
  # spotify-tui desktop entry
  home.file.".local/share/applications/spotify-tui.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=spotify-tui
      GenericName=spotify-tui
      Comment=Spotify in terminal
      Exec=${pkgs.wezterm}/bin/wezterm start --class="Spotify-TUI" -- ${pkgs.spotify-tui}/bin/spt
      Terminal=false
      Type=Application
      Keywords=music
      Icon=nix-snowflake
      Categories=Music;
    '';
  };
}
