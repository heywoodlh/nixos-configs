{ config, pkgs, lib, ... }:

{

  system.defaults.CustomSystemPreferences = {
    "com.apple.SoftwareUpdate" = {
      AutomaticallyInstallMacOSUpdates = lib.mkForce false; # disable updates on mac-mini for reboots to not break ssh access, i.e. getting stuck at login screen
    };
  };
}
