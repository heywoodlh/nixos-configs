{ config, pkgs, lib, home-manager, nur, spicetify, darwin, attic, ... }:


let
  hostname = "mac-mini";
  system = pkgs.system;
  atticClient = attic.packages.${system}.attic-client;
  darwinRebuild = darwin.packages.${system}.darwin-rebuild;
  populateCache = pkgs.writeShellScriptBin "nix-darwin-cache-populate" ''
    rm -rf /tmp/nixos-configs
    ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /tmp/nixos-configs
    cd /tmp/nixos-configs
    # Desktop
    ${darwinRebuild}/bin/darwin-rebuild build --flake .#${hostname} --impure
    ${atticClient}/bin/attic push nixos ./result
    ${atticClient}/bin/attic push nix-darwin ./result
    rm -rf /tmp/nixos-configs
  '';
in {
  imports = [
    ../roles/base.nix
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/pkgs.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../roles/sketchybar.nix
    ../../home/darwin/settings.nix
  ];

  # Set hostname
  networking.hostName = "${hostname}";

  # Applications specific to this machine
  homebrew = {
    brews = [
      "libheif"
      "libolm"
    ];
    casks = [
      "discord"
      "microsoft-remote-desktop"
      "screens"
      "signal"
      "vmware-fusion"
      "zoom"
    ];
  };

  home-manager.users.heywoodlh.home.packages = with pkgs; [
    moonlight-qt
    spicetify.packages.${system}.nord
  ];

  # Populate cache
  launchd.daemons.cache-populate = {
    command = "${populateCache}/bin/nix-darwin-cache-populate";
    serviceConfig.StartInterval = 86400; # run once a day
  };

  system.defaults.alf.globalstate = lib.mkForce 0;
  system.defaults.alf.stealthenabled = lib.mkForce 0;

  system.stateVersion = 4;
}
