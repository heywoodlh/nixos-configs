{ config, pkgs, signal-ntfy, ... }:

let
  system = pkgs.system;
  mk-systemd-service = { name, }: {
    description = "Mirror ${name}";
    path = [ pkgs.bash pkgs.coreutils ];
    environment = {
      NTFY_HOST = "http://ntfy.barn-banana.ts.net";
      NTFY_TOPIC = "${name}";
      SIGNAL_CLI_DIR = "/home/heywoodlh/.config/signal-cli";
      SIGNAL_DEST = "KC3d6Xu8HDjl3rNe81Bz2tZFW8k7askLWc3fUKoFWtc=";
      MESSAGE_PREFIX = "${name}";
      SIGNAL_GROUP = "true";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      User = "heywoodlh";
      ExecStart = "${signal-ntfy.packages.${system}.ntfy-mirror}/bin/main";
    };
    wantedBy = [ "multi-user.target" ];
  };
in {
  systemd.services = {
    ssh-notifications-mirror = mk-systemd-service { name = "ssh-notifications"; };
    plex-notifications-mirror = mk-systemd-service { name = "plex-notifications"; };
    uptime-notifications-mirror = mk-systemd-service { name = "uptime-notifications"; };
  };
}
