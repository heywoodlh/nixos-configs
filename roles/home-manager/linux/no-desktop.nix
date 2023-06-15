{ config, pkgs, home-manager, lib, ... }:

# Mainly, this file removes things we don't need from desktop builds
{
  home-manager.users.heywoodlh = {
    dconf.settings = lib.mkForce {};

    home.packages = with pkgs; lib.mkForce [
      colima
      curl
      docker-client
      glow
      htop
      jq
      kubectl
      lefthook
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

    programs.starship.enable = lib.mkForce false;

    programs.zsh.initExtra = ''
      PROMPT=$'%~ %F{green}$(git branch --show-current 2&>/dev/null) %F{red}$(env | grep -i SSH_CLIENT | grep -v '0.0.0.0' | cut -d= -f2 | awk \'{print $1}\' 2&>/dev/null) %F{white}\n> '
    '';
  };
}
