{ config, pkgs, nixpkgs-unstable, ... }:

let
  system = pkgs.system;
  unstable = nixpkgs-unstable.legacyPackages.${system};
in {
  imports = [
    (nixpkgs-unstable + /nixos/modules/services/web-apps/guacamole-client.nix)
    (nixpkgs-unstable + /nixos/modules/services/web-apps/guacamole-server.nix)
  ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8080
  ];

  services.guacamole-server = {
    enable = true;
    package = unstable.guacamole-server;
    userMappingXml = "/opt/guacamole/user-mapping.xml";
  };
  services.guacamole-client = {
    enable = true;
    package = unstable.guacamole-client;
  };
}
