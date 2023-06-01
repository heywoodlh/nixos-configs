{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 5900 ];
  };

  environment.systemPackages = with pkgs; [
    wayvnc
  ];

  systemd.services.wayvnc = {
    description = "WayVNC Service";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # Path to the wayvnc binary
      ExecStart = "${pkgs.wayvnc}/bin/wayvnc";
      # Command-line arguments for wayvnc
      ExecStartPost = "--config /home/heywoodlh/.config/wayvnc/config";
      # User and group to run the service as
      User = "heywoodlh";
      # Optionally, set working directory
      # WorkingDirectory = "/opt/wayvnc";
      # Optionally, specify additional environment variables
      # Environment = [
      #   "VAR=value"
      # ];
      # Restart service on failure
      Restart = "on-failure";
    };
 };
}
