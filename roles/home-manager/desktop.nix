{ config, pkgs, home-manager, nur, mullvad-browser-home-manager, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;

  mullvad-settings = {
    "browser.compactmode.show" = true; # enable compact bar
    "browser.privatebrowsing.autostart" = false; # don't start in private mode
    "privacy.history.custom" = false; # remember history
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # userChrome.css
  };

  firefox-settings = import ./firefox/modules/settings.nix;
  firefox-config = {
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
      settings = if system == "aarch64-linux"
      then
        firefox-settings
      else
        mullvad-settings
      ;
    };
  };

in {
  home.packages = [
    pkgs.mdp
  ];

  # Mullvad Browser configuration
  programs.mullvad-browser = if system != "aarch64-linux" then firefox-config else { enable = false; };
  # Firefox if on aarch64-linux
  programs.firefox = if system == "aarch64-linux" then firefox-config else { enable = false; };
}
