# Config specific to Razer Blade 15

{ config, pkgs, ... }:

{
  boot.kernelParams = [ "button.lid_init_state=open" ];
}
