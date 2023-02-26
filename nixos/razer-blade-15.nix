# Config specific to Razer Blade 15

{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [ "button.lid_init_state=open" ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
}
