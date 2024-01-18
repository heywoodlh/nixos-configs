{ config, pkgs, home-manager, nur, mullvad-browser-home-manager, ... }:

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

  # Mullvad Browser configuration
  programs.mullvad-browser = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then
      pkgs.runCommand "firefox-0.0.0" { } "mkdir $out"
    else
      pkgs.firefox.override {
        cfg = {
          enableGnomeExtensions = true;
        };
      }
    ;
    profiles.home-manager = {
      search.force = true; # This is required so the build won't fail each time
      bookmarks = import ./firefox/modules/bookmarks.nix;
      # View extensions here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
      extensions = import ./firefox/modules/extensions.nix { inherit pkgs; };
      userChrome = if pkgs.stdenv.isDarwin then
        import ./firefox/modules/macos-userchrome.nix
      else
        import ./firefox/modules/linux-userchrome.nix
      ;
      isDefault = true;
      name = "home-manager";
      search.default = "DuckDuckGo";
      settings = {
        "browser.compactmode.show" = true; # enable compact bar
        "browser.privatebrowsing.autostart" = false; # don't start in private mode
        "privacy.history.custom" = false; # remember history
      };
    };
  };
}
