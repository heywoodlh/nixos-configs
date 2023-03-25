{ config, pkgs, lib, ... }:

let
  user = {
    name =  "heywoodlh";
    full_name = "Spencer Heywood";
    description = "Spencer Heywood";
  };
in {
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
}
