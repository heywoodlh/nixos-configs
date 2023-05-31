{ config, pkgs, ... }:

{
  # Allow Sunshine ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      47984
      47989
      48010
    ];
    allowedUDPPorts = [
      47998
      47999
      48000
      48002
      48010
    ];
  };
  # Ensure Sunshine is installed
  environment.systemPackages = with pkgs; [
    sunshine
  ];
  # Define and start Sunshine service
  systemd.user.services.sunshine = {
    description = "Sunshine Gamestreaming Server";
    environment = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/sunshine";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
}
