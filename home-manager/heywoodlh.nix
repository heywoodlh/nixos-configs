{ config, pkgs, ... }:

let
  username = "heywoodlh";
  homedir = "/home/${username}";
  user_packages = [
    pkgs.aerc
    pkgs.ansible
    pkgs.appimage-run
    pkgs.awscli2
    pkgs.blueman
    pkgs.brave
    pkgs.caffeine-ng
    pkgs.chrome-gnome-shell
    pkgs.coreutils
    pkgs.dante
    pkgs.dos2unix
    pkgs.feh
    pkgs.ffmpeg
    pkgs.fzf
    pkgs.gcc
    pkgs.git
    pkgs.github-cli
    pkgs.glib
    pkgs.gnupg
    pkgs.go
    pkgs.helm
    pkgs.htop
    pkgs.iosevka
    pkgs.jq
    pkgs.kubectl
    pkgs.lefthook
    pkgs.lima
    pkgs.mosh
    pkgs.neofetch
    pkgs.nordic
    pkgs.openssh
    pkgs.pa_applet
    pkgs.pass
    pkgs.pinentry-gnome
    pkgs.pwgen
    (pkgs.python310.withPackages (ps: with ps;
    [
      pip
      setuptools
      websocket-client
    ]))
    pkgs.rofi
    pkgs.rofi-pass
    pkgs.scdoc
    pkgs.screen
    pkgs.slack
    pkgs.teams
    pkgs.tcpdump
    pkgs.inetutils
    pkgs.tmux
    pkgs.tor
    pkgs.torsocks
    pkgs.ventoy-bin
    pkgs.vim
    pkgs.vultr-cli
    pkgs.w3m
    pkgs.weechat
    pkgs.weechatScripts.wee-slack
    pkgs.wireguard-tools
    pkgs.xclip
    pkgs.zoom-us
  ];
in {
  home.username = "${username}";
  home.homeDirectory = "${homedir}";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages install
  home.packages = user_packages;

  # Enable syncthing
  #services.syncthing.enable = true;
}
