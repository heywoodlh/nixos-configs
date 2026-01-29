{ config, lib, pkgs, determinate-nix, ... }:

with lib;

let
  cfg = config.heywoodlh.home.determinate;
  system = pkgs.stdenv.hostPlatform.system;
  nixPkg = determinate-nix.packages.${system}.nix;
in {
  options = {
    heywoodlh.home.determinate.enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Determinate Nix configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    nix.package = nixPkg;
    home.packages = [
      nixPkg
    ];
  };
}
