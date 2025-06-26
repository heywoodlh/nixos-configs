{ config, determinate-nix, pkgs, attic, myFlakes, darwin, nixpkgs-apple-containers, ... }:

let
  system = pkgs.system;
  nixPkg = determinate-nix.packages.${system}.default;
  container = nixpkgs-apple-containers.legacyPackages.${system}.container;
  linuxBuilderSsh = pkgs.writeShellScriptBin "linux-builder-ssh" ''
    sudo ssh -i /etc/nix/builder_ed25519 builder@linux-builder
  '';
  darwinSwitch = pkgs.writeShellScriptBin "darwin-switch" ''
    /usr/bin/sudo darwin-rebuild switch --flake $HOME/opt/nixos-configs#$(hostname)
  '';
in {
  #nix packages
  environment.systemPackages = [
    container
    linuxBuilderSsh
    darwinSwitch
  ];

  nix.settings = {
    auto-optimise-store = false; # Breaks things
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
      "aaronraimist/tap/gomuks"
      "mas"
      "mosh"
      "pinentry-mac"
      "spice-gtk"
      "watch"
      "zsh"
    ];
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = [
      "amar1729/formulae"
      "colindean/fonts-nonfree"
      "kidonng/malt"
      "aaronraimist/homebrew-tap"
      "aaronraimist/tap"
    ];
    casks = [
      "1password"
      "android-platform-tools"
      "blockblock"
      "cursorcerer"
      "firefox"
      "font-jetbrains-mono-nerd-font"
      "font-microsoft-office"
      "ghostty"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "lulu"
      "oversight"
      "remoteviewer"
      "rustdesk"
      "shortcat"
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
