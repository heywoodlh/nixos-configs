{ config, pkgs, signal-ntfy, ... }:

let
  system = pkgs.system;
  wrapper = pkgs.writeShellScript "ntfy-mirror" ''
    source /home/heywoodlh/.config/signal-cli/vars.sh
    ${signal-ntfy.packages.${system}.ntfy-mirror}/bin/main
  '';
  mk-systemd-service = { name, }: {
    description = "Mirror ${name}";
    path = [ pkgs.bash pkgs.coreutils ];
    environment = {
      NTFY_HOST = "http://ntfy.barn-banana.ts.net";
      NTFY_TOPIC = "${name}";
      SIGNAL_CLI_DIR = "/home/heywoodlh/.config/signal-cli";
      MESSAGE_PREFIX = "${name}";
      #SIGNAL_GROUP = "true";
      #SIGNAL_ACCOUNT = ""; # Set in ~/.config/signal-cli/vars.sh
      #SIGNAL_DEST = ""; # Set in ~/.config/signal-cli/vars.sh
    };
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      User = "heywoodlh";
      ExecStart = "${wrapper}";
    };
    wantedBy = [ "multi-user.target" ];
  };
in {
  environment.systemPackages = with pkgs; [
    signal-cli
  ];
  systemd.services = {
    ssh-notifications-mirror = mk-systemd-service { name = "ssh-notifications"; };
    plex-notifications-mirror = mk-systemd-service { name = "plex-notifications"; };
    uptime-notifications-mirror = mk-systemd-service { name = "uptime-notifications"; };
    wazuh-notifications-mirror = mk-systemd-service { name = "wazuh-notifications"; };
  };
}
