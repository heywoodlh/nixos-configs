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
      purple-signald
      purple-matrix
    ];
    plugins = with pkgs; [
      bitlbee-discord
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
