{ config, pkgs, ... }:

{
  systemd.timers."rsync-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "rsync-backup.service";
    };
  };

  systemd.services."rsync-backup" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync 
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
