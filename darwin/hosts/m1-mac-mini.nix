{ config, pkgs, lib, home-manager, nur, vim-configs, fish-configs, ... }:


let
  hostname = "nix-m1-mac-mini";
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../../roles/home-manager/darwin/settings.nix
  ];

  # Define user settings
  users.users.${username} = import ../roles/user.nix { inherit config; inherit pkgs; };

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit fish-configs;
    };
    # Set home-manager configs for username
    users.${username} = import ../../roles/home-manager/darwin.nix;
  };

  # Set hostname
  networking.hostName = "${hostname}";

  # Applications specific to this machine
  homebrew = {
    casks = [
      "discord"
      "screens"
      "vmware-fusion"
      "zoom"
    ];
  };

  system.defaults.alf.globalstate = lib.mkForce 0;
  system.defaults.alf.stealthenabled = lib.mkForce 0;

  system.stateVersion = 4;
}
