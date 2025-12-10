{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.apple-silicon;
in {
  options.heywoodlh.apple-silicon = mkOption {
    default = false;
    description = ''
      Enable heywoodlh apple-silicon configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
    nixpkgs.config = {
      allowUnsupportedSystem = true;
    };

    hardware.asahi.enable = true;

    environment.sessionVariables = {
      COGL_DEBUG = "sync-frame";
      CLUTTER_PAINT = "disable-dynamic-max-render-time";
    };

    nix.settings = {
      extra-substituters = [
        "https://nixos-apple-silicon.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };

    # Workaround for Mesa 25.3.0 regression
    # https://github.com/nix-community/nixos-apple-silicon/issues/380
    hardware.graphics.package = assert pkgs.mesa.version == "25.3.0"; (import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/c5ae371f1a6a7fd27823bc500d9390b38c05fa55.tar.gz";
      sha256 = "sha256-4PqRErxfe+2toFJFgcRKZ0UI9NSIOJa+7RXVtBhy4KE=";
    }) { localSystem = pkgs.stdenv.hostPlatform; }).mesa;
  };
}
