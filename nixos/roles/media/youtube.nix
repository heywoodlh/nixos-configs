{ config, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  resolvConf = pkgs.writeText "resolv.conf" ''
    nameserver 1.1.1.1
    nameserver 1.0.0.1
  '';
  yt-dlp-wrapper = pkgs.writeShellScriptBin "yt-dlp-wrapper" ''
    sudo rm -rf /tmp/yt-dlp
    sudo -u media mkdir -p /tmp/yt-dlp
    sudo -u media HOME=/tmp/yt-dlp ${pkgs.nix}/bin/nix --extra-experimental-features "nix-command flakes" run "github:nixos/nixpkgs/master#yt-dlp" -- --user-agent "Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0" --cookies "/media/services/yt-dlp/cookies.txt" --cache-dir /tmp/yt-dlp -P "/media/home-media/disk3/videos/" $1
  '';
  youtube-dl = pkgs.writeShellScriptBin "youtube-dl" ''
    ntfy_uri="http://ntfy/plex-notifications"
    date="$(date +%Y%m%d-%H:%M:%S)"
    outfile="/tmp/youtube-dl-$date.log"
    ${yt-dlp-wrapper}/bin/yt-dlp-wrapper "$1" &> $outfile

    status=$?
    if [ $status -eq 0 ]; then
      message="Downloaded $1"
      echo "$message"
    else
      message="Failed to download $1. Logfile at $outfile"
      echo "$message"
    fi
    curl -d "$message" $ntfy_uri
  '';
in {
  networking.firewall.allowedTCPPorts = [
    6081
  ];

  environment.systemPackages = [
    youtube-dl
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      metube = {
        image = "ghcr.io/alexta69/metube:2024-12-14";
        autoStart = true;
        volumes = [
          "/media/home-media/disk2/videos:/downloads"
          "${resolvConf}:/etc/resolv.conf"
        ];
        ports = [
          "6081:8081"
        ];
        environment = {
          UID = "995";
          GID = "995";
          DEFAULT_THEME = "dark";
        };
      };
    };
  };
}
