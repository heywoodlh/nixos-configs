{ config, pkgs, ... }:

{
  description = "Spencer Heywood";
  name = "Spencer Heywood";
  shell = pkgs.powershell;
  packages = [
    pkgs.gcc
    pkgs.git
    pkgs.gnupg
    pkgs.pomerium-cli
    pkgs.powershell
    pkgs.skhd
    pkgs.tmux
    pkgs.wireguard-tools
  ];
}
