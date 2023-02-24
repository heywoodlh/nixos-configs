{ config, pkgs, lib, system, ... }:


let
  hostname = "nix-mac-chg";
  user_name = "sheywood";
  user_full_name = "Spencer Heywood";
  user_description = "Spencer Heywood";
in {
  imports = [
    ./desktop.nix
  ];

  users.users.${user_name} = {
    description = "${user_description}";
    home = "/Users/${user_name}";
    name = "${user_full_name}";
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
}
