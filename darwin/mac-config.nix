{ config, pkgs, ... }:

{
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  environment.shells = with pkgs; [
    bashInteractive
    fish
    zsh
    "/usr/locall/bin/fish"
    "/usr/local/bin/zsh"
    "/opt/homebrew/bin/fish"
  ];
}
