{ config, pkgs, user_name, user_description, user_full_name, .. }:

{
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
}
