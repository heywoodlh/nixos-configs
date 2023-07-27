{ config, pkgs, ... }:

let
  spicetify_theme = "Sleek";
  spicetify_color_scheme = "nord";
in {
  homebrew = {
    taps = [
      "spicetify/homebrew-tap"
    ];
    brews = [
      "spicetify-cli"
    ];
    casks = [
      "spotify"
    ];
  };

  system.activationScripts.extraActivation.enable = true;
  system.activationScripts.postUserActivation.text = ''
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    export themes_cloned="false"
    git clone --depth=1 https://github.com/spicetify/spicetify-themes.git ~/.config/spicetify/Themes 2>/dev/null || themes_cloned="true"
    [[ -e ~/Library/Application\ Support/Spotify ]] || open -a Spotify && sleep 5
    [[ -e ~/.config/spicetify/Backup/login.spa ]] || spicetify backup apply
    spicetify config current_theme ${spicetify_theme}
    spicetify config color_scheme ${spicetify_color_scheme}
    spicetify apply
  '';
}
