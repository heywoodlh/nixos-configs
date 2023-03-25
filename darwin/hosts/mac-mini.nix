# Remember that this is used for GitHub Actions to test builds
{ config, pkgs, lib, ... }:

let
  hostname = "nix-mac-mini";
in {
  imports = [
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/home.nix
    ../roles/user-heywoodlh.nix
  ];

  # Networking stuff specific to each machine
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
    hostName = "${hostname}";
    computerName = "${hostname}";
    localHostName = "${hostname}";
  };
}
