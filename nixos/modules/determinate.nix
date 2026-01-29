{ pkgs, config, lib, determinate-nix, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.determinate;
  system = pkgs.stdenv.hostPlatform.system;
  nixPkg = determinate-nix.packages.${system}.default;
in {
  options.heywoodlh.determinate.enable = mkOption {
    default = false;
    description = ''
      Enable heywoodlh Determinate NixOS configuration.
    '';
    type = bool;
  };

  config = mkIf cfg.enable {
    nix.package = nixPkg;
    environment.systemPackages = [
      nixPkg
    ];
    determinate.enable = true;
  };
}
