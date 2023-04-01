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

backup	root@nix-pomerium.wireguard:/etc/	nix-pomerium/
backup	root@nix-pomerium.wireguard:/home/	nix-pomerium/
backup	root@nix-pomerium.wireguard:/opt/	nix-pomerium/
backup	root@nix-pomerium.wireguard:/root/	nix-pomerium/

    '';
  };
}
