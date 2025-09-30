{ config, pkgs, lib, darwin, ... }:

let
  system = pkgs.system;
  atticServer = pkgs.attic-server;
  atticClient = pkgs.attic-client;
  darwinRebuild = darwin.packages.${system}.darwin-rebuild;
  configureCache = pkgs.writeShellScriptBin "nix-darwin-cache-config" ''
    ${atticClient}/bin/attic cache create nix-darwin
    ${atticClient}/bin/attic cache configure nix-darwin --public
    ${atticClient}/bin/attic cache configure nix-darwin --retention-period '3 months'
  '';
  garbageCollectCache = pkgs.writeShellScriptBin "nix-darwin-cache-garbage-collect" ''
    ${atticServer}/bin/atticd --mode garbage-collector-once &>>/tmp/binary-cache.log
  '';
  amd64Build = ''
    # Desktop
    ${darwinRebuild}/bin/darwin-rebuild build --flake .#nix-mac-mini --impure
    ${atticClient}/bin/attic push nixos ./result
  '';
  arm64Build = ''
    # Desktop
    ${darwinRebuild}/bin/darwin-rebuild build --flake .#mac-mini --impure
    ${atticClient}/bin/attic push nixos ./result
  '';
  build = if system == "x86_64-darwin" then amd64Build else arm64Build;
  populateCache = pkgs.writeShellScriptBin "nix-darwin-cache-populate" ''
    rm -rf /tmp/nixos-configs
    ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /tmp/nixos-configs
    cd /tmp/nixos-configs
    ${build}
    ${atticClient}/bin/attic push nix-darwin ./result
    rm -rf /tmp/nixos-configs
  '';
  runCache = pkgs.writeShellScript "serve-cache" ''
    ${atticServer}/bin/atticd --listen 0.0.0.0:8080 &>>/tmp/binary-cache.log
  '';
in {
  environment.systemPackages = [
    configureCache
    populateCache
  ];

  nix.settings = {
    substituters = [
      "http://attic/nix-darwin"
    ];
    trusted-public-keys = [
      "nix-darwin:qESxKY7Cmom/KKKD/3mmmajoQL7fvZ/VfDaodZMXPNM="
    ];
  };
}
