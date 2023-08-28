{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    6667
  ];

  services.bitlbee = {
    enable = true;
    configDir = "/opt/bitlbee/etc";
    portNumber = 6667;
    libpurple_plugins = with pkgs; [
      purple-discord
      purple-signald
      purple-matrix
    ];
    plugins = with pkgs; [
      bitlbee-mastodon
    ];
  };

  services.signald = {
    enable = true;
    group = "signald";
    socketPath = "/run/signald/signald.sock";
  };

  # Restart signald daily
  systemd.timers."restart-signald" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "restart-signald.service";
      };
  };
  systemd.services."restart-signald" = {
    script = ''
      set -eu
      systemctl restart signald.service
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };


  users.groups.signald.members = [
    "bitlbee"
    "heywoodlh"
    "signald"
  ];

  environment.systemPackages = with pkgs; [
    signaldctl
  ];
}
