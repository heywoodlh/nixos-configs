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

backup	root@nix-tools.tailscale:/etc/	nix-tools/
backup	root@nix-tools.tailscale:/home/	nix-tools/
backup	root@nix-tools.tailscale:/opt/	nix-tools/
backup	root@nix-tools.tailscale:/root/	nix-tools/

backup	root@nix-precision.tailscale:/etc/	nix-precision/
backup	root@nix-precision.tailscale:/home/	nix-precision/
backup	root@nix-precision.tailscale:/opt/	nix-precision/
backup	root@nix-precision.tailscale:/root/	nix-precision/

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

backup	root@nix-ext-net.tailscale:/etc/	nix-ext-net/
backup	root@nix-ext-net.tailscale:/home/	nix-ext-net/
backup	root@nix-ext-net.tailscale:/opt/	nix-ext-net/
backup	root@nix-ext-net.tailscale:/root/	nix-ext-net/

backup	root@nix-nvidia.tailscale:/etc/	nix-nvidia/
backup	root@nix-nvidia.tailscale:/home/	nix-nvidia/
backup	root@nix-nvidia.tailscale:/opt/	nix-nvidia/
backup	root@nix-nvidia.tailscale:/root/	nix-nvidia/

backup	root@nix-drive.tailscale:/etc/	nix-drive/
backup	root@nix-drive.tailscale:/home/	nix-drive/
backup	root@nix-drive.tailscale:/opt/	nix-drive/
backup	root@nix-drive.tailscale:/root/	nix-drive/
    '';
  };
}
