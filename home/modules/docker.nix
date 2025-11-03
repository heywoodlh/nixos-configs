{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.dockerBins;
  system = pkgs.stdenv.hostPlatform.system;
  homeDir = config.home.homeDirectory;
  docker-check = pkgs.writeShellScript "docker-check" ''
    # Ensure docker is running
    if ! ${pkgs.docker-client}/bin/docker ps &> /dev/null
    then
      echo 'Docker does not seem to be running. Exiting'
      exit 1
    fi
  '';
  docker-multiarch = pkgs.writeShellScriptBin "docker-multiarch" ''
    # Enable multi-arch support
    if [[ $(uname) == "Linux" ]]
    then
      # nixos support
      if ls -l /run/wrappers/bin/sudo &> /dev/null
      then
        sudo_bin=/run/wrappers/bin/sudo
      else
        sudo_bin=sudo
      fi
      exec "$sudo_bin" ${pkgs.docker-client}/bin/docker run --privileged --rm docker.io/tonistiigi/binfmt --install all
    else
      ${pkgs.docker-client}/bin/docker run --privileged --rm docker.io/tonistiigi/binfmt --install all
    fi
  '';
  check-multiarch = pkgs.writeShellScript "check-multiarch" ''
    ${docker-check} || exit 1
    if ! ${pkgs.docker-client}/bin/docker buildx inspect --bootstrap | grep Platforms | grep 'linux/amd64' | grep -q 'linux/arm'
    then
      ${docker-multiarch}/bin/docker-multiarch || exit 1
    fi
  '';
  sniper = pkgs.writeShellScriptBin "sniper" ''
    # Ensure multiarch support
    ${check-multiarch} || exit 1
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
  msfconsole = let
    metasploitDockerfile = pkgs.writeText "Dockerfile" ''
      FROM docker.io/heywoodlh/metasploit:latest
      RUN apt update && apt install -y ca-certificates
    '';
    proxychainsConf = pkgs.writeText "proxychains.conf" ''
      strict_chain
      proxy_dns
      quiet_mode
      remote_dns_subnet 224
      tcp_read_time_out 15000
      tcp_connect_time_out 8000
      localnet 127.0.0.0/255.0.0.0
      [ProxyList]
      socks5 100.115.177.85 1080
    '';
    databaseyaml = pkgs.writeText "database.yml" ''
      ---
      production:
        adapter: postgresql
        database: msf
        username: msf
        password: msf
        host: msfdb
        port: 5432
        pool: 75
        timeout: 5
    '';
    msfcompose = pkgs.writeText "compose.yaml" ''
      services:
        metasploit:
          build:
            context: /
            dockerfile: ${metasploitDockerfile}
          command: "/usr/bin/msfconsole --execute-command 'db_connect postgres:msf@127.0.0.1:5432/msf'"
          network_mode: "host"
          environment:
            PATH: "/run/current-system/sw/bin:/usr/local/nix/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            PROXYCHAINS_CONF_FILE: /proxychains.conf
          volumes:
            - msf_data:/root/.msf4
            - /nix:/nix
            - /run/current-system/sw/bin:/run/current-system/sw/bin
            - ${homeDir}/.nix-profile/bin:/usr/local/nix/bin
            - ${proxychainsConf}:/proxychains.conf:ro
            - ${databaseyaml}:/database.yml:ro
            - ${homeDir}/Downloads:/root/Downloads
            - /etc/nix/nix.conf:/etc/nix/nix.conf:ro
            - /tmp/metasploit:/tmp
        msfdb:
          image: "docker.io/postgres:14"
          volumes:
            - msf_database:/var/lib/postgresql/data
          environment:
            POSTGRES_DB: msf
            POSTGRES_PASSWORD: msf
          ports:
            - "127.0.0.1:5432:5432"
      volumes:
        msf_database:
        msf_data:
    '';
  in pkgs.writeShellScriptBin "msfconsole" ''
    ${docker-check} || exit 1
    ${pkgs.docker-client}/bin/docker compose -f ${msfcompose} up -d msfdb
    ${pkgs.docker-client}/bin/docker compose -f ${msfcompose} run --rm metasploit /usr/bin/msfconsole --execute-command 'db_connect postgres:msf@127.0.0.1:5432/msf' $@
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
      pkgs.docker-client
      docker-multiarch
      gscript
      sniper
      nuclei
      msfconsole
    ];
  };
}
