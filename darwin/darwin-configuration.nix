{ config, pkgs, darwin, ... }:

let
  hostname = "changeme";
in {
  imports = [
    ./desktop.nix
  ];

  #nixpkgs.overlays = [
  #  ( import ./overlays/yabai.nix )
  #];

  #Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # M1 Support
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
    experimental-features = nix-command flakes
  '';

  # Networking stuff specific to each machine
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
    hostName = "${hostname}";
    computerName = "${hostname}";
    localHostName = "${hostname}";
  };

  system.stateVersion = 4;
}
