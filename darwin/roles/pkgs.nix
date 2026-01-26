{ config, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  linuxBuilderSsh = pkgs.writeShellScriptBin "linux-builder-ssh" ''
    sudo ssh -i /etc/nix/builder_ed25519 builder@linux-builder
  '';
  darwinRebuildWrapper = pkgs.writeShellScript "nixos-rebuild-wrapper" ''
    [[ -d $HOME/opt/nixos-configs ]] || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs $HOME/opt/nixos-configs
    /usr/bin/sudo darwin-rebuild $1 --flake $HOME/opt/nixos-configs#$(hostname) ''${@:2}
  '';
  myDarwinSwitch = pkgs.writeShellScriptBin "darwin-switch" ''
    ${darwinRebuildWrapper} switch $@
  '';
  myDarwinBoot = pkgs.writeShellScriptBin "darwin-boot" ''
    ${darwinRebuildWrapper} boot $@
  '';
  myDarwinBuild = pkgs.writeShellScriptBin "darwin-build" ''
    ${darwinRebuildWrapper} build $@
  '';
  myDarwinSwitchWithFlakes = pkgs.writeShellScriptBin "darwin-switch-with-flakes" ''
    ${myDarwinSwitch}/bin/darwin-switch --override-input myFlakes $HOME/opt/flakes $@
  '';
in {
  #nix packages
  environment.systemPackages = [
    linuxBuilderSsh
    myDarwinSwitch
    myDarwinBoot
    myDarwinBuild
    myDarwinSwitchWithFlakes
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
      "ollama"
      "opencode"
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
      "ghostty@tip"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "lulu"
      "oversight"
      "proton-drive"
      "remoteviewer"
      "rustdesk"
      "shortcat"
    ];
    masApps = {
      "Meshtastic" = 1586432531;
    };
  };
}
