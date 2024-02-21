{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    libvirt
  ];

  home.file.".config/fish/config.fish".text = ''
    function aerc
      set aerc_bin (which aerc)
      op-unlock && $aerc_bin $argv
    end
  '';

  # So that `nix search` works
  nix = lib.mkForce {
    package = pkgs.nix;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
  };
}
