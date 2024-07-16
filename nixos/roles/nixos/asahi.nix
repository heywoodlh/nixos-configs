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
    enable = true;
    withRust = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = false;
  };

  environment.sessionVariables = rec {
    COGL_DEBUG = "sync-frame";
    CLUTTER_PAINT = "disable-dynamic-max-render-time";
  };

  boot.extraModprobeConfig = ''
    options hid_apple swap_fn_leftctrl=1
  '';
}
