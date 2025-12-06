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

    boot.kernelPackages = lib.mkForce intel-mac-pkgs.linuxKernel.packages.linux_xanmod_latest;
    boot.kernelModules = lib.mkForce [ "kvm-intel" "wl" ];
    boot.extraModulePackages = lib.mkForce [ intel-mac-pkgs.linuxKernel.packages.linux_xanmod_latest.broadcom_sta ];

    nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) ["broadcom-sta"];
    environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";
  };
}
