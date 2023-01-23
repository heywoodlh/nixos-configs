{ config, pkgs, lib, ... }:

{
  virtualisation.virtualbox.host.enable = lib.mkForce false;
  users.extraGroups.vboxusers.members = lib.mkForce [];
  programs.steam.enable = lib.mkForce false;

  # Set fn key to ctrl
  boot.extraModprobeConfig = ''
    options hid_apple swap_fn_leftctrl=1
    options hid_apple iso_layout=0
  '';

  # Replace docker rootless with podman (due to lack of network connectivity)
  virtualisation = {
    docker.rootless.enable = lib.mkForce false;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Better trackpad config changes
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.additionalOptions = ''
    Option "DisableWhileTyping" "true"
  '';

  users.users.heywoodlh.packages = lib.mkForce [
    pkgs.abootimg
    pkgs.alacritty
    pkgs.apfs-fuse
    pkgs.appimage-run
    pkgs.aerc
    pkgs.ansible
    pkgs.argocd
    pkgs.automake
    pkgs.awscli2
    pkgs.bind
    pkgs.bitwarden-cli
    pkgs.calcurse
    pkgs.cargo
    pkgs.chromium
    pkgs.cmake
    pkgs.coreutils
    pkgs.curl
    pkgs.dante
    pkgs.docker-compose
    pkgs.gnome.dconf-editor
    pkgs.go
    pkgs.evolution
    pkgs.evolution-data-server
    pkgs.evolution-ews
    pkgs.ffmpeg
    pkgs.file
    pkgs.firefox
    pkgs.freshfetch
    pkgs.fzf
    pkgs.gcc
    pkgs.git
    pkgs.github-cli
    pkgs.gitleaks
    pkgs.glib.dev
    pkgs.glow
    pkgs.gnome.gnome-boxes
    pkgs.gnome.gnome-tweaks
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.hide-top-bar
    pkgs.gnomeExtensions.pop-shell
    pkgs.gnomeExtensions.tray-icons-reloaded
    pkgs.gnumake
    pkgs.gnupg
    pkgs.go
    pkgs.gotify-cli
    pkgs.gotify-desktop
    pkgs.guake
    pkgs.htop
    pkgs.inotify-tools
    pkgs.jq
    pkgs.k9s
    pkgs.keyutils
    pkgs.kind
    pkgs.kitty
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.libarchive
    pkgs.libnotify
    pkgs.libreoffice
    pkgs.lima
    pkgs.matrix-commander
    pkgs.moonlight-qt
    pkgs.nixos-generators
    pkgs.nixos-install-tools
    pkgs.nodejs
    pkgs.lefthook
    pkgs.mosh
    pkgs.neovim
    pkgs.nerdfonts
    pkgs.nim
    pkgs.nordic
    pkgs.openssl
    pkgs.pandoc
    pkgs.pass 
    (pkgs.pass.withExtensions (ext: with ext; 
    [ 
      pass-otp 
    ])) 
    pkgs.pciutils
    pkgs.peru
    pkgs.pinentry-gnome
    pkgs.plex-media-player
    pkgs.procmail
    pkgs.unstable.powershell
    pkgs.pwgen
    pkgs.python310Full
    pkgs.qemu-utils
    pkgs.unstable.rbw
    pkgs.remmina
    pkgs.rofi
    pkgs.unstable.rofi-rbw
    pkgs.rpi-imager
    pkgs.scrot
    pkgs.tcpdump
    pkgs.thunderbird
    pkgs.tmux
    pkgs.tree
    pkgs.unzip
    pkgs.uxplay
    pkgs.vim
    pkgs.virt-manager
    pkgs.vultr-cli
    pkgs.w3m
    pkgs.wireguard-tools
    pkgs.xautomation
    pkgs.xclip
    pkgs.xdotool
    pkgs.zsh
  ];
}
