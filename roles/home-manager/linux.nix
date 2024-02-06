{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    libvirt
  ];

  # So that `nix search` works
  nix = lib.mkForce {
    package = pkgs.nix;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
  };
}
