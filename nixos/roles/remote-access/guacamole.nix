{ config, pkgs, nixpkgs-unstable, ... }:

let
  system = pkgs.system;
  unstable = nixpkgs-unstable.legacyPackages.${system};
in {
  imports = [
    (nixpkgs-unstable + /nixos/modules/services/web-apps/guacamole-client.nix)
    (nixpkgs-unstable + /nixos/modules/services/web-apps/guacamole-server.nix)
  ];

  services.guacamole-server = {
    enable = true;
    package = unstable.guacamole-server;
  };
  services.guacamole-client = {
    enable = true;
    package = unstable.guacamole-client;
  };
}
