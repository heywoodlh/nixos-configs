{ config, pkgs, lib, home-manager, browsh, ... }:

let
  homeDir = config.home.homeDirectory;
  signersFile = pkgs.writeText "allowed_signers" ''
    github@heywoodlh.io ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ==
  '';
  cpuspeed = pkgs.writeShellScriptBin "cpuspeed" ''
    sudo ${pkgs.dmidecode}/bin/dmidecode -t processor | ${pkgs.gnugrep}/bin/grep -i mhz
  '';
  system = pkgs.system;
  myProxychains = pkgs.writeShellScriptBin "proxychains" ''
    ${pkgs.proxychains-ng}/bin/proxychains4 "$@"
  '';
  browshPkg = browsh.packages.${system}.default;
  myBrowsh = pkgs.writeShellScriptBin "browsh" ''
    ${myProxychains}/bin/proxychains ${browshPkg}/bin/browsh $@
  '';
in {
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    gomuks
    libvirt
    cpuspeed
    myBrowsh
    myProxychains
  ];

  home.file.".config/fish/config.fish".text = ''
    function aerc
      set aerc_bin (which aerc)
      op-unlock && $aerc_bin $argv
    end
  '';

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

  heywoodlh.home.dockerBins.enable = true;
}
