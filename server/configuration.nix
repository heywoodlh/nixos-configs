{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./server.nix
      ./network.nix
      ./firewall.nix
    ];

  system.stateVersion = "20.03";
}
