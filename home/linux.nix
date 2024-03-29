{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    libvirt
  ];

  home.file.".config/fish/config.fish".text = ''
    function aerc
      set aerc_bin (which aerc)
      op-unlock && $aerc_bin $argv
    end
  '';

  # So that `nix search` works
  nix = lib.mkForce {
    package = pkgs.nix;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
  };

  # Proxychains wrapper
  home.file."bin/proxychains" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pkgs.proxychains-ng}/bin/proxychains4 "$@"
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
}
