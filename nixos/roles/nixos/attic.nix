{ config, lib, pkgs, ... }:

{
  nix.settings = {
    extra-substituters = [
      "http://attic.barn-banana.ts.net/nixos"
    ];
    trusted-public-keys = [
      "nixos:4q9iokR56gpJfsHh0UKn9Hj1cPplvM879XVgnRstpNU=" # attic
    ];
    connect-timeout = lib.mkDefault 5;
    fallback = lib.mkDefault true;
  };
}
