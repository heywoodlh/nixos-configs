{ pkgs, config, lib, nvidia-patch, nixpkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.nvidia-patch;
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-nvidia = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ nvidia-patch.overlays.default ];
  };
  # possible versions for the package here: https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
  targetPkg = config.boot.kernelPackages.nvidiaPackages.latest;
  pkgAfterFbc = if builtins.hasAttr targetPkg.version pkgs-nvidia.nvidia-patch-list.fbc
                then pkgs-nvidia.nvidia-patch.patch-fbc targetPkg
                else targetPkg;
  finalPkg   = if builtins.hasAttr targetPkg.version pkgs-nvidia.nvidia-patch-list.nvenc
                then pkgs-nvidia.nvidia-patch.patch-nvenc pkgAfterFbc
                else pkgAfterFbc;
in {
  options.heywoodlh.nixos.nvidia-patch = mkOption {
    default = false;
    description = ''
      Enable heywoodlh nvidia-patch configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    heywoodlh.nixos.cachyos-kernel.enable = true;
    hardware.graphics = {
      enable = true;
    };
    services.xserver.videoDrivers = ["nvidia"];
    boot = {
      kernelParams = [
        "nvidia.NVreg_UsePageAttributeTable=1"
        "NVreg_InitializeSystemMemoryAllocations=0"
        "NVreg_RegistryDwords=RMIntrLockingMode=1"
      ];
    };
    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
      package = finalPkg;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
    };

    services.xserver.deviceSection = ''
      Option         "TripleBuffer" "on"
      Option         "Coolbits" "28"
    '';

    services.xserver.screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
    '';
  };
}
