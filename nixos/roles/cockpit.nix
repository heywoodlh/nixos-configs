{ config, pkgs, nur, ... }:

{
  # Enable cockpit
  services.cockpit = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs.nur.repos.dukzcry; [
    cockpit-machines
  ];
}
