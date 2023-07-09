{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  description = "Spencer Heywood";
  name = "heywoodlh";
  home = "/Users/heywoodlh";
  shell = "/run/current-system/sw/bin/zsh";
  packages = [
    pkgs.gcc
    pkgs.git
    pkgs.gnupg
    pkgs.pomerium-cli
    pkgs.skhd
    pkgs.tmux
    pkgs.wireguard-tools
    pkgs.zsh
  ];
}
