{ config, pkgs, lib, nixos-apple-silicon, ... }:

{
  imports = [
    (nixos-apple-silicon + "/apple-silicon-support")
  ];
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  nixpkgs.config = {
    allowUnsupportedSystem = true;
  };

  hardware.asahi = {
    withRust = true;
    addEdgeKernelConfig = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
  };

  boot.extraModprobeConfig = ''
    options hid_apple swap_fn_leftctrl=1
  '';
}
