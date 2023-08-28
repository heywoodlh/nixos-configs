{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    3000
  ];

  services.hydra = {
    enable = true;
    hydraURL = "http://0.0.0.0:3000";
    notificationSender = "hydra@heywoodlh.io";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
