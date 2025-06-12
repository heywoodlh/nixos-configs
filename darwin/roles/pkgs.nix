{ config, pkgs, attic, myFlakes, darwin, nixpkgs-apple-containers, ... }:

let
  system = pkgs.system;
  container = nixpkgs-apple-containers.legacyPackages.${system}.container;
  linuxBuilderSsh = pkgs.writeShellScriptBin "linux-builder-ssh" ''
    sudo ssh -i /etc/nix/builder_ed25519 builder@linux-builder
  '';
  pkgs-darwin = darwin.packages.${system};
  darwinSwitch = pkgs.writeShellScriptBin "darwin-switch" ''
    [[ -d ~/opt/nixos-configs ]] || git clone https://github.com/heywoodlh/nixos-configs
    #${pkgs.git}/bin/git -C ~/opt/nixos-configs pull origin master --rebase
    ${pkgs-darwin.darwin-rebuild}/bin/darwin-rebuild switch --flake ~/opt/nixos-configs#$(hostname)
  '';
  dockerWrapper = pkgs.writeShellScriptBin "docker" ''
    # Docker compatibility wrapper
    [ $1 == "ps" ] && subcommand="list"
    [ -z $subcommand ] && subcommand="$1"
    shift
    ${container}/bin/container $subcommand $@
  '';
in {
  #nix packages
  environment.systemPackages = [
    container
    linuxBuilderSsh
    darwinSwitch
    dockerWrapper
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
      "syncthing"
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
