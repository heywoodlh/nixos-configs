{ config, pkgs, ... }:

{
  description = "Spencer Heywood";
  name = "Spencer Heywood";
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
