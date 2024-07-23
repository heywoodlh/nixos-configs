{ config, pkgs, docker-multiarch, ... }:

let
  sniper = pkgs.writeShellScriptBin "sniper" ''
    # Ensure multiarch support
    ${docker-multiarch}/bin/docker-multiarch || exit 1
    ${pkgs.git}/bin/git clone https://github.com/1N3/Sn1per /tmp/sniper || true
    cd /tmp/sniper
    ${pkgs.docker-client}/bin/docker compose up --abort-on-container-exit
    ${pkgs.docker-client}/bin/docker docker run -it sn1per-kali-linux /bin/bash
  '';
in {
  home.packages = [ sniper ];
}
