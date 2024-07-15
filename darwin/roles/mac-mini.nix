{ config, pkgs, lib, ... }:

{
  # Disable firewall to allow SSH, VNC
  system.defaults.alf.globalstate = lib.mkForce 0;
  system.defaults.alf.stealthenabled = lib.mkForce 0;
}
