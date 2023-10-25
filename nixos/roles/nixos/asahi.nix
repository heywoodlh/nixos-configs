{ config, pkgs, lib, nixos-apple-silicon, ... }:

{
  imports = [
    (nixos-apple-silicon + "/apple-silicon-support")
  ];
  boot.kernelPackages = lib.mkForce pkgs.linux-asahi;
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  nixpkgs.config = {
    allowUnsupportedSystem = true;
  };
  boot.extraModprobeConfig = ''
    options hid_apple swap_fn_leftctrl=1
  '';
}
