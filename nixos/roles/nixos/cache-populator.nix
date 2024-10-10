{ config, pkgs, attic, ... }:

let
  system = pkgs.system;
  atticClient = attic.packages.${system}.attic-client;
  configureCache = pkgs.writeShellScriptBin "nixos-cache-config" ''
    ${atticClient}/bin/attic cache create nixos
    ${atticClient}/bin/attic cache configure nixos --public
    ${atticClient}/bin/attic cache configure nixos --retention-period '3 months'
  '';
  populateCache = pkgs.writeShellScriptBin "nixos-cache-populate" ''
    rm -rf /tmp/nixos-configs
    ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /tmp/nixos-configs
    cd /tmp/nixos-configs
    # ARM64 builds
    ## Desktop
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-arm64-test --impure
    ${atticClient}/bin/attic push nixos ./result
    ## Server
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-mac-mini --impure
    ${atticClient}/bin/attic push nixos ./result
    # x86_64 builds
    ## Desktop
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-desktop-intel --impure
    ${atticClient}/bin/attic push nixos ./result
    ## Server
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-server-intel --impure
    ${atticClient}/bin/attic push nixos ./result
    rm -rf /tmp/nixos-configs
  '';
  populateWrapper = pkgs.writeShellScriptBin "nixos-cache-populate" ''
    sudo ${populateCache}/bin/nixos-cache-populate
  '';
in {
  environment.systemPackages = [
    atticClient
    configureCache
    populateWrapper
  ];
  systemd.timers."populate-cache" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "populate-cache.service";
      };
  };
  systemd.services."populate-cache" = {
    script = ''
      set -eu
      ${populateCache}/bin/nixos-cache-populate
    '';
    path = with pkgs; [
      git
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # Allow cross compile
  boot.binfmt.emulatedSystems = if system == "aarch64-linux" then [ "x86_64-linux" ] else [ "aarch64-linux" ];
}
