{ pkgs, nvidia-patch, nixpkgs-nvidia, ... }:
let
  system = pkgs.system;
  pkgs-nvidia = import nixpkgs-nvidia {
    inherit system;
    config.allowUnfree = true;
    overlays = [ nvidia-patch.overlays.default ];
  };
  # possible versions for the package here: https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
  package = pkgs-nvidia.linuxKernel.packages.linux_zen.nvidiaPackages.beta;
  nvidiaVersion = package.version;
in {
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelPackages = pkgs-nvidia.linuxKernel.packages.linux_zen;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = if builtins.hasAttr nvidiaVersion pkgs-nvidia.nvidia-patch-list.fbc
    then
      pkgs-nvidia.nvidia-patch.patch-nvenc (pkgs-nvidia.nvidia-patch.patch-fbc package)
    else
      throw "Nvidia package provided by nixpkgs does not have patch available for version ${nvidiaVersion}";
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
