{ config, pkgs, ... }:

{
  services.rsnapshot = {
    enable = true;
    enableManualRsnapshot = true;
    cronIntervals = {
      hourly = "0 * * * *";
      daily = "30 5 * * *";
      weekly = "0 8 * * 1";
      monthly = "0 13 1 * *";
    };
    extraConfig = ''
#Separate everything with tabs, not spaces	
#Convert spaces to tabs in vim with :%s/\s\+/\t/g
logfile	/media/backups/log/rsnapshot.log
snapshot_root	/media/backups/
retain	hourly	24
retain	daily	7
retain	weekly	4
retain	monthly	6

backup	root@ct-1.tailscale:/etc/	ct-1/
backup	root@ct-1.tailscale:/home/	ct-1/	exclude=/home/heywoodlh/.local/share/docker
backup	root@ct-1.tailscale:/opt/	ct-1/
backup	root@ct-1.tailscale:/root/	ct-1/
backup	root@ct-1.tailscale:/media/disk2/ct-storage/	ct-1/	exclude=/media/disk2/ct-storage/nextcloud

backup	root@nix-pomerium.tailscale:/etc/	nix-pomerium/
backup	root@nix-pomerium.tailscale:/home/	nix-pomerium/
backup	root@nix-pomerium.tailscale:/opt/	nix-pomerium/
backup	root@nix-pomerium.tailscale:/root/	nix-pomerium/

backup	root@nix-tools.tailscale:/etc/	nix-tools/
backup	root@nix-tools.tailscale:/home/	nix-tools/
backup	root@nix-tools.tailscale:/opt/	nix-tools/
backup	root@nix-tools.tailscale:/root/	nix-tools/

backup	root@arch-precision.tailscale:/etc/	arch-precision/
backup	root@arch-precision.tailscale:/home/	arch-precision/
backup	root@arch-precision.tailscale:/opt/	arch-precision/
backup	root@arch-precision.tailscale:/root/	arch-precision/

backup	root@tools.tailscale:/etc/	tools/
backup	root@tools.tailscale:/home/	tools/
backup	root@tools.tailscale:/opt/	tools/
backup	root@tools.tailscale:/root/	tools/

backup	root@nix-media.tailscale:/etc/	nix-media/
backup	root@nix-media.tailscale:/home/	nix-media/
backup	root@nix-media.tailscale:/opt/	nix-media/
backup	root@nix-media.tailscale:/root/	nix-media/
backup	root@nix-media.tailscale:/media/services/freshrss/	nix-media/
backup	root@nix-media.tailscale:/media/services/sabnzbd/	nix-media/
backup	root@nix-media.tailscale:/media/services/radarr/	nix-media/
backup	root@nix-media.tailscale:/media/services/sonarr/	nix-media/
backup	root@nix-media.tailscale:/media/services/tautulli/	nix-media/

backup	root@matrix.tailscale:/etc/	matrix/
backup	root@matrix.tailscale:/home/	matrix/
backup	root@matrix.tailscale:/opt/	matrix/
backup	root@matrix.tailscale:/root/	matrix/
backup	root@matrix.tailscale:/matrix/	matrix/
    '';
  };
}
