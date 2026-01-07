{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.defaults;
in {
  options = {
    heywoodlh.home.defaults = mkOption {
      default = false;
      description = ''
        Enable heywoodlh home-manager defaults.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.stateVersion = "25.05";
    home.enableNixpkgsReleaseCheck = false;

    nix = {
      extraOptions = ''
        extra-experimental-features = nix-command flakes pipe-operators
      '';
      settings = {
        auto-optimise-store = true;
        trusted-users = [
          config.home.username
        ];
        extra-substituters = [
          "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
