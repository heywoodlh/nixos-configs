{ pkgs, nvidia-patch, nixpkgs-backports, ... }:
let
  system = pkgs.system;
  pkgs-stable = import nixpkgs-backports {
    inherit system;
    config.allowUnfree = true;
    overlays = [ nvidia-patch.overlays.default ];
  };
  package = pkgs-stable.linuxKernel.packages.linux_zen.nvidiaPackages.beta;
in {
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelPackages = pkgs-stable.linuxKernel.packages.linux_zen;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = pkgs-stable.nvidia-patch.patch-nvenc (pkgs-stable.nvidia-patch.patch-fbc package);
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
