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
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "amar1729/formulae"
      "colindean/fonts-nonfree"
      "kidonng/malt"
      "aaronraimist/homebrew-tap"
    ];
    casks = [
      "1password-beta"
      "android-platform-tools"
      "blockblock"
      "cursorcerer"
      "font-droid-sans-mono-for-powerline"
      "font-iosevka-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-microsoft-office"
      "hammerspoon"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "lulu"
      "mullvad-browser"
      "oversight"
      "reikey"
      "rustdesk"
      "secretive"
      "shortcat"
      "syncthing"
      "tailscale"
    ];
    masApps = {
      DaisyDisk = 411643860;
      "WiFi Explorer" = 494803304;
      "Reeder 5." = 1529448980;
      "1Password for Safari" = 1569813296;
      "Dark Reader for Safari" = 1438243180;
      "Redirect Web for Safari" = 1571283503;
      "Vimlike" = 1584519802;
      "AdGuard for Safari" = 1440147259;
    };
  };
}
