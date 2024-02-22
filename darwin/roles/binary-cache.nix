{ config, pkgs, lib, attic, ... }:

let
  system = pkgs.system;
  atticServer = attic.packages.${system}.attic-server;
  atticClient = attic.packages.${system}.attic-client;
  configureCache = pkgs.writeShellScriptBin "nix-darwin-cache-config" ''
    ${atticClient}/bin/attic cache create nix-darwin
    ${atticClient}/bin/attic cache configure nix-darwin --public
    ${atticClient}/bin/attic cache configure nix-darwin --retention-period '7d'
  '';
  garbageCollectCache = pkgs.writeShellScriptBin "nix-darwin-cache-garbage-collect" ''
    ${atticServer}/bin/atticd --mode garbage-collector-once &>>/tmp/binary-cache.log
  '';
  populateCache = pkgs.writeShellScriptBin "nix-darwin-cache-populate" ''
    rm -rf /tmp/nixos-configs
    ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /tmp/nixos-configs
    cd /tmp/nixos-configs
    # aarch64 build
    ${pkgs.nix}/bin/nix build .#darwinConfigurations.mac-mini.config.system.build.toplevel
    ${atticClient}/bin/attic push nix-darwin ./result

    rm -rf /tmp/nixos-configs
  '';
  runCache = pkgs.writeShellScript "serve-cache" ''
    ${atticServer}/bin/atticd --listen 0.0.0.0:8080 &>>/tmp/binary-cache.log
  '';
in {
  launchd.daemons.cache-populate = {
    command = "${populateCache}/bin/nix-darwin-cache-populate";
    serviceConfig.StartInterval = 86400; # run once a day
  };

  launchd.daemons.cache-garbage-collect = {
    command = "${populateCache}/bin/nix-darwin-cache-garbage-collect";
    serviceConfig.StartInterval = 604800; # run once a week
  };

  launchd.daemons.nix-cache = {
    command = "${runCache}";
    serviceConfig.RunAtLoad = true;
  };

  environment.systemPackages = [
    configureCache
    garbageCollectCache
    populateCache
  ];

  nix.settings.substituters = lib.mkForce [
    "http://127.0.0.1:8080/nix-darwin"
  ];
}
