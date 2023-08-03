{ config, pkgs, ... }:

# Nord-themed Spicetify for MacOS
# Before running this, either:
# - Install Homebrew
# - Install Spotify

let
  spicetify_theme = "Sleek";
  spicetify_color_scheme = "nord";
in {
  homebrew = {
    casks = [
      "spotify"
    ];
  };

  system.activationScripts.extraActivation.enable = true;
  system.activationScripts.postUserActivation.text = ''
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    export themes_cloned="false"
    ${pkgs.git}/bin/git clone --depth=1 https://github.com/spicetify/spicetify-themes.git ~/.config/spicetify/Themes 2>/dev/null || themes_cloned="true"
    [[ -e ~/Library/Application\ Support/Spotify ]] || /usr/bin/open -a Spotify && sleep 5
    [[ -e ~/.config/spicetify/Backup/login.spa ]] || ${pkgs.spicetify-cli}/bin/spicetify-cli backup apply
    ${pkgs.spicetify-cli}/bin/spicetify-cli config current_theme ${spicetify_theme}
    ${pkgs.spicetify-cli}/bin/spicetify-cli config color_scheme ${spicetify_color_scheme}
    ${pkgs.spicetify-cli}/bin/spicetify-cli apply
  '';
}
