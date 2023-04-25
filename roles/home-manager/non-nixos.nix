{ config, pkgs, home-manager, ... }:

{
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "Iosevka" "JetBrainsMono" ]; })
  ];
}
