{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.dockerBins;
  system = pkgs.system;
  docker-check = pkgs.writeShellScript "docker-check" ''
    # Ensure docker is running
    if ! ${pkgs.docker-client}/bin/docker ps &> /dev/null
    then
      echo 'Docker does not seem to be running. Exiting'
      exit 1
    fi
  '';
  docker-multiarch = pkgs.writeShellScriptBin "docker-multiarch" ''
    ${docker-check} || exit 1
    # Enable multi-arch support
    if ! ${pkgs.docker-client}/bin/docker buildx inspect --bootstrap | grep Platforms | grep -q 'linux/amd64'
    then
       ${pkgs.docker-client}/bin/docker run --privileged --rm tonistiigi/binfmt --install all
    fi
  '';
  sniper = pkgs.writeShellScriptBin "sniper" ''
    # Ensure multiarch support
    ${docker-multiarch}/bin/docker-multiarch || exit 1
    mkdir -p ~/share/docker
    ${pkgs.git}/bin/git clone https://github.com/1N3/Sn1per ~/share/docker/sniper &>/dev/null || true
    ${pkgs.docker-client}/bin/docker compose --project-directory=$HOME/share/docker/sniper up
    mkdir -p ~/share/docker/sniper/data
    ${pkgs.docker-client}/bin/docker run -v $HOME/share/docker/sniper/data:/data -w /data -it --rm sniper-kali-linux /bin/bash
  '';
in {
  options = {
    heywoodlh.home.dockerBins = {
      enable = mkOption {
        default = false;
        description = ''
          Add heywoodlh docker executables to home.packages.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      docker-multiarch
      sniper
    ];
  };
}
