# Config specific to Razer Blade 15

{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [ "button.lid_init_state=open" ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  disabledModules = [ "hardware/video/nvidia.nix" ];

  imports =
    [ # sudo nix-channel --add https://github.com/GoogleBot42/nixpkgs/archive/refs/heads/master.tar.gz nvidia-reverse-prime 
      <nvidia-reverse-prime/nixos/modules/hardware/video/nvidia.nix>
    ];

  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      reverse_sync.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
}
