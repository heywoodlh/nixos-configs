{ config, pkgs, lib, home-manager, ... }:

let
  homeDir = config.home.homeDirectory;
  signersFile = pkgs.writeText "allowed_signers" ''
    github@heywoodlh.io ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ==
  '';
  cpuspeed = pkgs.writeShellScriptBin "cpuspeed" ''
    sudo ${pkgs.dmidecode}/bin/dmidecode -t processor | ${pkgs.gnugrep}/bin/grep -i mhz
  '';
in {
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    gomuks
    libvirt
    cpuspeed
  ];

  home.file.".config/fish/config.fish".text = ''
    function aerc
      set aerc_bin (which aerc)
      op-unlock && $aerc_bin $argv
    end
  '';

  # Proxychains wrapper
  home.file."bin/proxychains" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pkgs.proxychains-ng}/bin/proxychains4 "$@"
    '';
  };

  home.file.".config/git/config" = {
    text = ''
[user]
  signingkey = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ==

[gpg]
  format = ssh

[gpg.ssh]
allowedSignersFile = ${signersFile}

[commit]
  gpgsign = true
    '';
  };

  # Proxychains configs
  home.file.".proxychains/proxychains.conf" = {
    enable = true;
    text = ''
      strict_chain
      proxy_dns
      quiet_mode
      remote_dns_subnet 224
      tcp_read_time_out 15000
      tcp_connect_time_out 8000
      localnet 127.0.0.0/255.0.0.0
      [ProxyList]
      socks5 100.108.77.60 1080
    '';
  };

  # Gnupg settings
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  # FBTerm config
  home.file.".config/fbterm/fbtermrc" = {
    enable = true;
    text = ''
      font-names=JetBrainsMono Nerd Font
      font-size=14
      #font-width=
      #font-height=

      # terminal palette consists of 256 colors (0-255)
      # 0 = black, 1 = red, 2 = green, 3 = brown, 4 = blue, 5 = magenta, 6 = cyan, 7 = white
      # 8-15 are brighter versions of 0-7
      # 16-231 is 6x6x6 color cube
      # 232-255 is grayscale
      # Nord theme, from https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/kitty/nord.conf
      color-0=3B4252
      color-1=BF616A
      color-2=A3BE8C
      color-3=EBCB8B
      color-4=81A1C1
      color-5=B48EAD
      color-6=88C0D0
      color-7=E5E9F0
      color-8=4C566A
      color-9=BF616A
      color-10=A3BE8C
      color-11=EBCB8B
      color-12=81A1C1
      color-13=B48EAD
      color-14=8FBCBB
      color-15=ECEFF4
      color-foreground=D8DEE9
      color-background=2E3440

      history-lines=0
      text-encodings=

      # cursor shape: 0 = underline, 1 = block
      # cursor flash interval in milliseconds, 0 means disable flashing
      cursor-shape=1
      cursor-interval=500

      # additional ascii chars considered as part of a word while auto-selecting text, except ' ', 0-9, a-z, A-Z
      word-chars=._-

      # change the clockwise orientation angle of screen display
      # available values: 0 = 0 degree, 1 = 90 degrees, 2 = 180 degrees, 3 = 270 degrees
      #screen-rotate=0

      # specify the favorite input method program to run
      input-method=
    '';
  };
  heywoodlh.home.dockerBins.enable = true;
}
