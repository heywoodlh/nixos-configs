{ config, pkgs, darwin, ... }:

{
  imports = [
    ./system-defaults.nix
    ./modules/security/pam.nix
    ./network.nix
    ./wm.nix
    ./mac-config.nix
    ./packages.nix
    ./users.nix
  ];

  nixpkgs.overlays = [
    ( import ./overlays/yabai.nix )
  ];

  #Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # M1 Support
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
    experimental-features = nix-command flakes
  '';

  system.stateVersion = 4;
}
