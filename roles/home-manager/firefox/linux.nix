{ config, pkgs, nur, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = {
        enableGnomeExtensions = true;
      };
    };
    profiles.default = {
      search.force = true; # This is required so the build won't fail each time
      bookmarks = import ./modules/bookmarks.nix;
      # View extensions here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
      extensions = import ./modules/extensions.nix { inherit pkgs; };
      userChrome = import ./modules/linux-userchrome.nix;
      isDefault = true;
      name = "default";
      search.default = "DuckDuckGo";
      settings = import ./modules/settings.nix;
    };
  };
}
