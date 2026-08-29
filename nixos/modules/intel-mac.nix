{ config, pkgs, nixpkgs-stable, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.intel-mac;
  system = pkgs.stdenv.hostPlatform.system;
  intel-mac-pkgs = import nixpkgs-stable {
    inherit system;
    config = {
      allowUnfree = true;
      allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" "intel-media-sdk"];
    };
  };
in {
  options.heywoodlh.intel-mac = mkOption {
    default = false;
    description = ''
      Enable configuration for Intel-based Macs.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    # Intel hardware acceleration
    hardware.graphics = {
      enable = true;
      extraPackages = with intel-mac-pkgs; [
        intel-vaapi-driver
        libvdpau-va-gl
        intel-media-sdk
      ];
    };

    # Use the default kernel from the same nixpkgs as the NixOS modules (`pkgs`).
    # A kernel from a different (older) nixpkgs lacks passthru attrs the modules
    # now read (e.g. kernel.buildDTBs, kernel.target), which breaks evaluation.
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
    boot.kernelModules = lib.mkForce [ "kvm-intel" "wl" ];
    boot.extraModulePackages = lib.mkForce [ pkgs.linuxPackages.broadcom_sta ];

    # broadcom-sta is allowed via the single predicate in defaults.nix
    environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";
  };
}
