{ config, pkgs, lib, ... }:


let
  hostname = "generic-m1";
  user = {
    name =  "heywoodlh";
    full_name = "Spencer Heywood";
    description = "Spencer Heywood";
  };
in {
  imports = [
    ../desktop.nix
  ];

  users.users."${user.name}" = {
    description = "${user.description}";
    home = "/Users/${user.name}";
    name = "${user.full_name}";
    shell = pkgs.powershell;
    packages = [
      pkgs.gcc
      pkgs.git
      pkgs.gnupg
      pkgs.powershell
      pkgs.skhd
      pkgs.tmux
      pkgs.wireguard-tools
    ];
  };

  # Networking stuff specific to each machine
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
    hostName = "${hostname}";
    computerName = "${hostname}";
    localHostName = "${hostname}";
  };

  # Include extra architecture 
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
  '';
}
