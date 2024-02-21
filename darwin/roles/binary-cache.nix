{ config, pkgs, attic, darwin, ... }:

let
  system = pkgs.system;
  darwinRebuild = darwin.packages.${system}.darwin-rebuild;
  atticServer = attic.packages.${system}.attic-server;
  populateCache = pkgs.writeShellScript "nix-build" ''
    ${darwinRebuild}/bin/darwin-rebuild build --flake "github:heywoodlh/nixos-configs#mac-mini" # aarch64 build
    ${darwinRebuild}/bin/darwin-rebuild build --flake "github:heywoodlh/nixos-configs#nix-mac-mini" # x86_64 build
  '';
  runCache = pkgs.writeShellScript "serve-cache" ''
    ${atticServer}/bin/atticd &>>/tmp/binary-cache.log
  '';
  garbageCollectCache = pkgs.writeShellScript "cacheCollectGarbage" ''
    ${atticServer}/bin/atticd --mode garbage-collector-once &>>/tmp/binary-cache.log
  '';
in {
  launchd.daemons.cache-populate = {
    command = "${populateCache}";
    serviceConfig.StartInterval = 86400; # run once a day
  };

  launchd.daemons.cache-garbage-collect = {
    command = "${populateCache}";
    serviceConfig.StartInterval = 604800; # run once a week
  };

  launchd.daemons.nix-cache = {
    command = "${runCache}";
  };
}
