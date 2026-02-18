{ pkgs, config, nvidia-patch, nixpkgs-stable, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-nvidia = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
    overlays = [ nvidia-patch.overlays.default ];
  };
  # possible versions for the package here: https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
  stablePkg = config.boot.kernelPackages.nvidiaPackages.stable;
  pkgAfterFbc = if builtins.hasAttr stablePkg.version pkgs-nvidia.nvidia-patch-list.fbc
                then pkgs-nvidia.nvidia-patch.patch-fbc stablePkg
                else stablePkg;
  finalPkg   = if builtins.hasAttr stablePkg.version pkgs-nvidia.nvidia-patch-list.nvenc
                then pkgs-nvidia.nvidia-patch.patch-nvenc pkgAfterFbc
                else pkgAfterFbc;
in {
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelPackages = pkgs-nvidia.linuxKernel.packages.linux_zen;
  hardware.nvidia = {
    modesetting.enable = true;
    package = finalPkg;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
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
}
