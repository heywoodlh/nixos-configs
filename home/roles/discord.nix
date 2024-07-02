{ config, pkgs, snowflake, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  discordIcon = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/simple-icons/simple-icons/aaddf57e792cd70c2bfe44cb5ac13f4331dfd583/icons/discord.svg";
    sha256 = "sha256:1mck6h5khkw27fmy429v1zf0h4slzgc8ra3ws4vzxwgar5r4ndhx";
  };
in {
  # Webcord
  home.file.".local/share/applications/discord.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=Discord
      GenericName=discord
      Comment=Discord
      Exec=${pkgs.webcord}/bin/webcord
      Terminal=false
      Type=Application
      Keywords=webcord;discord;messenger;
      Icon=${discordIcon}
      Categories=Utility;
    '';
  };

  # Webcord theme
  home.file."share/applications/webcord-nord-theme.css" = {
    enable = true;
    source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/orblazer/discord-nordic/bfd1da7e7a9a4291cd8f8c3dffc6a93dfc3d39d7/nordic.theme.css";
      sha256 = "sha256:13q4ijdpzxc4r9423s51hhcc8wzw3901cafqpnyqxn69vr2xnzrc";
    };
  };

  # Webcord config
  home.file.".local/share/applications/configure-discord.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=Discord Theme
      GenericName=configure-discord
      Comment=Add CSS theme to webcord
      Exec=${pkgs.webcord}/bin/webcord --add-css-theme
      Terminal=false
      Type=Application
      Keywords=webcord;discord;
      Icon=${snowflake}
      Categories=Utility;
    '';
  };
}
