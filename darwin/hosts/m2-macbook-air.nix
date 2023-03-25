{ config, pkgs, lib, ... }:


let
  hostname = "nix-macbook-air";

in {
  imports = [
    ../roles/m1.nix
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

  # Always show menu bar on M2 Macbook Air 
  system.defaults.NSGlobalDomain._HIHideMenuBar = lib.mkForce false;
}
