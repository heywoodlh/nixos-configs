{ config, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [
      "bash"
      "choose-gui"
      "cliclick"
      "pinentry-mac"
      "watch"
      "zsh"
    ];
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
      "amar1729/formulae"
      "colindean/fonts-nonfree"
      "kidonng/malt"
      "aaronraimist/homebrew-tap"
    ];
    casks = [
      "alacritty"
      "android-platform-tools"
      "bitwarden"
      "blockblock"
      "caffeine"
      "cursorcerer"
      "firefox"
      "font-droid-sans-mono-for-powerline"
      "font-iosevka-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-microsoft-office"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "lastpass"
      "lulu"
      "microsoft-remote-desktop"
      "microsoft-teams"
      "oversight"
      "plexamp"
      "reikey"
      "rustdesk"
      "secretive"
      "shortcat"
      "slack"
      "syncthing"
      "tailscale"
    ];
    #masApps = {
      #DaisyDisk = 411643860;
      #Vimari = 1480933944;
      #"WiFi Explorer" = 494803304;
      #"Reeder 5." = 1529448980;
      #"Okta Extension App" = 1439967473;
    #};
  };
}
