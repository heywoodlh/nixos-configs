{ config, pkgs, home-manager, lib, ... }:

# Mainly, this file removes things we don't need from desktop builds
{
  home-manager.users.heywoodlh.dconf.settings = lib.mkForce {
  };

  home-manager.users.heywoodlh.home.packages = with pkgs; lib.mkForce [
    curl
    glow
    htop
    jq
    lefthook
    lima
    pandoc
    rbw
    tcpdump
    tmux
    tree
    w3m
    vim
    zsh
  ];

  home-manager.users.heywoodlh.programs.alacritty = lib.mkForce {
    enable = false;
  };

  home-manager.users.heywoodlh.programs.firefox = lib.mkForce {
    enable = false;
  };
}
