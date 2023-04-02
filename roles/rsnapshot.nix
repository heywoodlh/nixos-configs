{ config, pkgs, ... }:

{
  services.rsnapshot = {
    enable = true;
    enableManualRsnapshot = true;
    cronIntervals = {
      daily = "0 3 * * *";
      hourly = "0 * * * *";
      weekly = "0 1 * * 1";
      monthly = "0 1 1 * *";
    };
    extraConfig = ''
#Separate everything with tabs, not spaces	
#Convert spaces to tabs in vim with :%s/\s\+/\t/g
snapshot_root	/media/backups/
retain	hourly	24
retain	daily	7
retain	weekly	4
retain	monthly	6

backup	root@ct-1.wireguard:/etc/	ct-1/
backup	root@ct-1.wireguard:/home/	ct-1/
backup	root@ct-1.wireguard:/opt/	ct-1/
backup	root@ct-1.wireguard:/root/	ct-1/
backup	root@ct-1.wireguard:/media/disk2/ct-storage	ct-1/

backup	root@nix-pomerium.wireguard:/etc/	nix-pomerium/
backup	root@nix-pomerium.wireguard:/home/	nix-pomerium/
backup	root@nix-pomerium.wireguard:/opt/	nix-pomerium/
backup	root@nix-pomerium.wireguard:/root/	nix-pomerium/

backup	root@nix-tools.wireguard:/etc/	nix-tools/
backup	root@nix-tools.wireguard:/home/	nix-tools/
backup	root@nix-tools.wireguard:/opt/	nix-tools/
backup	root@nix-tools.wireguard:/root/	nix-tools/

backup	root@arch-precision.wireguard:/etc/	arch-precision/
backup	root@arch-precision.wireguard:/home/	arch-precision/
backup	root@arch-precision.wireguard:/opt/	arch-precision/
backup	root@arch-precision.wireguard:/root/	arch-precision/
backup	root@arch-precision.wireguard:/virtual-machines/	arch-precision/
backup	root@arch-precision.wireguard:/virtual-machines-2/	arch-precision/

backup	root@tools.wireguard:/etc/	tools/
backup	root@tools.wireguard:/home/	tools/
backup	root@tools.wireguard:/opt/	tools/
backup	root@tools.wireguard:/root/	tools/

backup	root@nix-media.wireguard:/etc/	nix-media/
backup	root@nix-media.wireguard:/home/	nix-media/
backup	root@nix-media.wireguard:/opt/	nix-media/
backup	root@nix-media.wireguard:/root/	nix-media/
backup	root@nix-media.wireguard:/media/services/freshrss/	nix-media/
backup	root@nix-media.wireguard:/media/services/sabnzbd/	nix-media/
backup	root@nix-media.wireguard:/media/services/radarr/	nix-media/
backup	root@nix-media.wireguard:/media/services/sonarr/	nix-media/
backup	root@nix-media.wireguard:/media/services/tautulli/	nix-media/
    '';
  };
}
