{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    5000
    6667
  ];

  # Use znc to maintain connections to IRC servers
  services.znc = {
    enable = true;
    dataDir = "/opt/znc";
    confOptions = {
      port = 5000;
      useSSL = false;
      networks."bitlbee" = {
        server = "localhost";
        port = 6667;
        hasBitlbeeControlChannel = true;
      };
    };
  };

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

  users.groups.signald.members = [
    "bitlbee"
    "heywoodlh"
    "signald"
  ];

  environment.systemPackages = with pkgs; [
    signaldctl
  ];
}
