{ pkgs, ... }:

let
  darwinRebuildWrapper = pkgs.writeShellScript "darwin-rebuild-wrapper" ''
    if [[ -d $HOME/opt/nixos-configs ]]
    then
      target="$HOME/opt/nixos-configs"
    else
      target="git+https://tangled.org/heywoodlh.io/nixos-configs"
    fi
    /usr/bin/sudo darwin-rebuild $1 --flake "$target#$(hostname)" ''${@:2}
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
  environment.systemPackages = with pkgs; [
    myDarwinSwitch
    myDarwinBoot
    myDarwinBuild
    myDarwinSwitchWithFlakes
    tailscale
  ];

  #homebrew packages
  homebrew = {
    brews = [
      "bash"
      "choose-gui"
      "cliclick"
      "aaronraimist/tap/gomuks"
      "mas"
      "mosh"
      "newsboat"
      "pinentry-mac"
      "spice-gtk"
      "watch"
      "zsh"
    ];
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = [
      { name = "amar1729/formulae"; trusted = true; }
      { name = "colindean/fonts-nonfree"; trusted = true; }
      { name = "kidonng/malt"; trusted = true; }
      { name = "aaronraimist/homebrew-tap"; trusted = true; }
      { name = "aaronraimist/tap"; trusted = true; }
      { name = "akdev1l/apps"; trusted = true; } # librewolf
    ];
    casks = [
      "1password"
      "android-platform-tools"
      "blockblock"
      "cursorcerer"
      "font-jetbrains-mono-nerd-font"
      "font-microsoft-office"
      "ghostty@tip"
      "helium-browser"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "akdev1l/apps/librewolf"
      "lulu"
      "moonlight"
      "oversight"
      "proton-drive"
      "remoteviewer"
      "rustdesk"
      "shortcat"
      "soduto"
      "tailscale-app"
    ];
    masApps = {
      "Meshtastic" = 1586432531;
    };
  };
}
