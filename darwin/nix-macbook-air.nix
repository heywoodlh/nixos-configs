{ config, pkgs, lib, ... }:


let
  hostname = "nix-macbook-air";
  user_name = "heywoodlh";
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
  
  # Always show menu bar on M2 Macbook Air 
  system.defaults.NSGlobalDomain._HIHideMenuBar = lib.mkForce false;

  # Include extra architecture 
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
  '';
}
