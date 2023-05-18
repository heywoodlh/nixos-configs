{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "envoy-1.25.1"
    "envoy-1.25.1-deps.tar.gz"
  ];

  services.pomerium = {
    enable = true;
    configFile = /opt/pomerium/config.yaml;
  };
}
