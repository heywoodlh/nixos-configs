{ config, pkgs, nur, ... }:

{
  programs.firefox = {
    enable = true;
    # Handled by the Homebrew module
    # This populates a dummy package to satsify the requirement
    package = pkgs.runCommand "firefox-0.0.0" { } "mkdir $out";
    profiles.default = {
      search.force = true; # This is required so the build won't fail each time
      bookmarks = import ./modules/bookmarks.nix;
      # View extensions here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
      extensions = import ./modules/extensions.nix { inherit pkgs; };
      userChrome = import ./modules/macos-userchrome.nix;
      isDefault = true;
      name = "default";
      search.default = "DuckDuckGo";
      settings = import ./modules/settings.nix;
    };
  };
}
