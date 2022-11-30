# Config specific to Razer Blade 15

{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [ "button.lid_init_state=open" ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    config = 
    ''
      Section "ServerLayout"
          Identifier "layout"
          Screen 0 "intel"
          Inactive "nvidia"
          Option "AllowNVIDIAGPUScreens"
      EndSection
      
      Section "Device"
          Identifier "nvidia"
          Driver "nvidia"
      EndSection
      
      Section "Screen"
          Identifier "nvidia"
          Device "nvidia"
      EndSection
      
      Section "Device"
          Identifier "intel"
          Driver "modesetting"
          BusID "PCI:0:2:0"
      EndSection
      
      Section "Screen"
          Identifier "intel"
          Device "intel"
      EndSection
    '';
  };
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  #hardware.nvidia = {
  #  powerManagement.enable = true;
  #  modesetting.enable = true;
  #  prime = {
  #    sync.enable = true;
  #    nvidiaBusId = "PCI:1:0:0";
  #    intelBusId = "PCI:0:2:0";
  #  };
  #};
}
