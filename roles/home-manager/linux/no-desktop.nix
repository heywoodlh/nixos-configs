{ config, pkgs, home-manager, lib, ... }:

# Mainly, this file removes things we don't need from desktop builds
{
  home-manager.users.heywoodlh = {
    dconf.settings = lib.mkForce {};

    home.packages = with pkgs; lib.mkForce [
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
  
    programs.alacritty = lib.mkForce {
      enable = false;
    };
  
    programs.firefox = lib.mkForce {
      enable = false;
    };

    programs.vscode = lib.mkForce {
      enable = false;
    };
  };
}
