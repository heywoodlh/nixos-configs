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
    mkdir -p ~/share/docker/sniper/loot
    ${pkgs.docker-client}/bin/docker run -v $HOME/share/docker/sniper/loot:/usr/share/sniper/loot -w /usr/share/sniper/loot -it --rm sniper-kali-linux /bin/bash
  '';
  gscript = pkgs.writeShellScriptBin "gscript" ''
    ${docker-check} || exit 1
    mkdir -p ~/share/docker/gscript
    ${pkgs.docker-client}/bin/docker run -it --rm -v $PWD:/workdir -w /workdir -v $HOME/share/docker/gscript:/root/gscript docker.io/heywoodlh/gscript:1.0.0 $@
  '';
  nuclei = pkgs.writeShellScriptBin "nuclei" ''
    ${docker-check} || exit 1
    mkdir -p ~/share/docker/nuclei/templates
    mkdir -p ~/share/docker/nuclei/config
    ${pkgs.docker-client}/bin/docker run --rm -v $HOME/share/docker/nuclei/templates:/root/nuclei-templates -v $HOME/share/docker/nuclei/config:/root/.config/nuclei -v $PWD:/data -w /data --net host -it docker.io/projectdiscovery/nuclei
  '';
  msfconsole = pkgs.writeShellScriptBin "msfconsole" ''
    ${docker-check} || exit 1
    mkdir -p ~/share/docker/metasploit/
    ${pkgs.docker-client}/bin/docker run -it --rm --net=host -v $HOME/share/docker/metasploit/:/root/.msf4 -w /root/session -v "$PWD:/root/session" docker.io/heywoodlh/metasploit msfconsole $args
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
      gscript
      sniper
      nuclei
      msfconsole
    ];
  };
}
