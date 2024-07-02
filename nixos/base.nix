# Configuration loaded for all NixOS hosts
{ config, pkgs, ... }:

{
  imports = [
    #./roles/nixos/cache-client.nix
  ];
  # So that `nix search` works
  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';
  # Automatically optimize store for better storage
  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [
      "heywoodlh"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "http://attic/nixos"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos:ZffGHlb0Ng3oXu8cLT9msyOB/datC4r+/K9nImONIec="
    ];
  };

  environment.systemPackages = with pkgs; [
    gptfdisk
  ];

  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;
}
