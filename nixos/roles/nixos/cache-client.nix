{ config, pkgs, attic, ... }:

let
  system = pkgs.system;
  atticClient = attic.packages.${system}.attic-client;
  configureCache = pkgs.writeShellScriptBin "nixos-cache-config" ''
    ${atticClient}/bin/attic cache create nixos
    ${atticClient}/bin/attic cache configure nixos --public
    ${atticClient}/bin/attic cache configure nixos --retention-period '3 months'
  '';
  amd64Build = ''
    # Desktop
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-desktop-intel --impure
    ${atticClient}/bin/attic push nixos ./result
    # Server
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-server-intel --impure
    ${atticClient}/bin/attic push nixos ./result

  '';
  arm64Build = ''
    # Desktop
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-arm64-test --impure
    ${atticClient}/bin/attic push nixos ./result
    # Server
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-mac-mini --impure
    ${atticClient}/bin/attic push nixos ./result
  '';
  build = if system == "x86_64-linux" then amd64Build else arm64Build;
  populateCache = pkgs.writeShellScriptBin "nixos-cache-populate" ''
    rm -rf /tmp/nixos-configs
    ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /tmp/nixos-configs
    cd /tmp/nixos-configs
    ${build}
    rm -rf /tmp/nixos-configs
  '';
in {
  nix.settings = {
    substituters = [
      "http://attic/nixos"
    ];
    trusted-public-keys = [
      "nixos:ZffGHlb0Ng3oXu8cLT9msyOB/datC4r+/K9nImONIec="
    ];
  };
  environment.systemPackages = [
    atticClient
    configureCache
  ];
}
