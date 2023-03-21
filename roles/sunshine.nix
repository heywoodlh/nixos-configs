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
  systemd.services.sunshine = {
    description = "Sunshine Gamestreaming Server";
    path = [
      pkgs.bash
      pkgs.sunshine
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
      User = "heywoodlh";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
