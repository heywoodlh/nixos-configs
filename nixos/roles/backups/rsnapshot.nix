{ config, pkgs, ... }:

let
  chown_script = pkgs.writeShellScriptBin "chown-rsnapshot" ''
    #!/usr/bin/env bash
    chown -R root:backups /media/backups/
    chmod -R g+r /media/backups
  '';
in {
  # Create backup user and group
  users = {
    groups = {
      backups = {};
    };
    users.backups = {
      createHome = true;
      isNormalUser = true;
      description = "backups";
      group = "backups";
      home = "/home/backups";
      shell = "${pkgs.bash}/bin/bash";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCWVwzFL5oZVH5wvKTJDmJW1TDqzhL4dXpLIHBVuZ/1sRnR4CiK1vDRhkoVCl1H1BFfAEwTbBfH4UsFjd59GUarzNcWhPJieqN12wIObTpKXsrTCt0vX9akjdFkgqvOkaS6GuvXT+ymPRWSiWpoJtNqUWervLcb3WGauL7fuKgZ4tMQebMTGKbdL5benK144vB2KlDpuH+76cKtg1R0EeD0e4LubRDKy3doCuI6g0Dj8uRtifg69ux75H6g8kPSEQ9FJFuqW2KQt8w1GRr3vSdCO1UqnE7l7NkxtaqBcJPP1cm+GEhW5Toz6fVPe0oON1IfeosFnKIrR7Ayokc/kiTPhp9qgX6XBZWvbiRRxy3hG7f1LehRHwGOVts0onKgct24aeIHROe46EhCdErmRZ/H8Xi2mInRGgnHWu5eDJN2F4lbyZa7S4hV61FsuCLmF7BYzWZ2XblaDj62ACO9wdaKTw+jioPWnvtZidj9+orVU5YGIkgavDKAiklZjdQcuOJp1nVBqL7L8oHoDsTgjI2O4NL+Qt2604mMk4ndDcBJUS7bylvOQQwnPrPrTgF3vdMbuE7QzYehwM4TBjANc5m4THT8oFLxJ3A9W5QjWhNUAB8NA1PMLdt7NXKBmjjvyTcPp+Rvi/6cahLYBA/SOmUUsjvQZONb2TmXifIYzoxX2Q== nix-drive"
      ];
    };
  };

  services.openssh.settings.Macs = [
   "hmac-sha2-512-etm@openssh.com"
   "hmac-sha2-256-etm@openssh.com"
   "umac-128-etm@openssh.com"
   "hmac-sha2-256"
   "hmac-sha1-96"
   "hmac-sha1"
   "hmac-md5-96"
   "hmac-md5"
  ];

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

backup	root@homelab:/etc/	homelab/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@homelab:/opt/	homelab/
backup	root@homelab:/root/	homelab/

cmd_postexec	${chown_script}/bin/chown-rsnapshot
    '';
  };
}
