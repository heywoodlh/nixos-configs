{ config, pkgs, lib, ... }:

{
  system.defaults.NSGlobalDomain._HIHideMenuBar = lib.mkForce false;
}
