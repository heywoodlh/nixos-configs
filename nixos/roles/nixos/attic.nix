{ config, pkgs, ... }:

{
  nix.settings = {
    extra-substituters = [
      "http://attic.barn-banana.ts.net/nixos"
    ];
    trusted-public-keys = [
      "nixos:pU2PdLt/QaDk8nec7lcy8DgsM96NTJ1bAOSs+jdoECc=" # attic
    ];
  };
}
