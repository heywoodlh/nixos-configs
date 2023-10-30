{ config, pkgs, home-manager, nur, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
in {
  home.packages = [
    pkgs.mdp
  ];

  # Webcord Nord theme
  home.file.".config/WebCord/Themes/nordic.theme.css" = {
    source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/orblazer/discord-nordic/bfd1da7e7a9a4291cd8f8c3dffc6a93dfc3d39d7/nordic.theme.css";
      sha256 = "sha256:13q4ijdpzxc4r9423s51hhcc8wzw3901cafqpnyqxn69vr2xnzrc";
    };
  };
}
