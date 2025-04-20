{ config, pkgs, ... }:

let
  wakeCorsair = pkgs.writeShellScriptBin "wake-corsair.sh" ''
    set -ex

    targetmac="10:FF:E0:4E:A7:A9" # corsair
    targetip="192.168.1.255"
    targetport="9"

    ${pkgs.wakeonlan}/bin/wakeonlan -i $targetip -p $targetport $targetmac
  '';
  wakeOryx = pkgs.writeShellScriptBin "wake-oryx.sh" ''
    set -ex

    targetmac="54:BF:64:96:06:32" # precision
    targetip="192.168.1.255"
    targetport="9"

    ${pkgs.wakeonlan}/bin/wakeonlan -i $targetip -p $targetport $targetmac
  '';
in {
  # Wake daily for updates
  systemd.timers."wake-gaming-pcs" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = [
          "*-*-* 2:00:00"
          "*-*-* 2:15:00"
          "*-*-* 2:30:00"
          "*-*-* 2:45:00"
          "*-*-* 3:00:00"
          "*-*-* 3:15:00"
          "*-*-* 3:30:00"
          "*-*-* 3:45:00"
        ];
        Unit = "wake-gaming-pcs.service";
      };
  };
  systemd.services."wake-gaming-pcs" = {
    script = ''
      set -eu
      ${wakeCorsair}/bin/wake-corsair.sh
      ${wakeOryx}/bin/wake-oryx.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # Placed in home dir for ease over Apple Shortcuts :)
  home-manager.users.heywoodlh.home.file = {
    "bin/wake-oryx.sh" = {
      enable = true;
      executable = true;
      source = "${wakeOryx}/bin/wake-oryx.sh";
    };
    "bin/wake-corsair.sh" = {
      enable = true;
      executable = true;
      source = "${wakeCorsair}/bin/wake-corsair.sh";
    };
  };
}
