{ config, pkgs, attic, ... }:

let
  system = pkgs.system;
  atticClient = attic.packages.${system}.attic-client;
  linuxBuilderSsh = pkgs.writeShellScriptBin "linux-builder-ssh" ''
    sudo ssh -i /etc/nix/builder_ed25519 builder@linux-builder
  '';
in {
  #nix packages
  environment.systemPackages = [
    atticClient
    linuxBuilderSsh
  ];

  nix.settings = {
    auto-optimise-store = false; # Breaks things
    substituters = [
      "http://mac-mini:8080/nix-darwin"
    ];
    trusted-public-keys = [
      "nix-darwin:zqwtaTJFoluKxoYMF6FZXHIzGtPeuKbv7TQZscovOP0="
    ];
  };

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
      "coder"
      "flyctl"
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
      "1password"
      "android-platform-tools"
      "blockblock"
      "cursorcerer"
      "firefox"
      "font-droid-sans-mono-for-powerline"
      "font-iosevka-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-microsoft-office"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "lulu"
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
