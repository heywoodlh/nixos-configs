{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.vmware-workstation;
in {
  options.heywoodlh.nixos.vmware-workstation = mkOption {
    default = false;
    description = ''
      Enable heywoodlh VMWare host configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    virtualisation.vmware.host = {
      enable = true;
      package = pkgs.vmware-workstation.override { enableMacOSGuests = true; };
      extraConfig = ''
        wsFeatureDarkModeSupported = "TRUE"
        mks.gl.allowUnsupportedDrivers = "TRUE"
        mks.vk.allowUnsupportedDevices = "TRUE"
      '';
    };

    environment.systemPackages = with pkgs; [
      vmware-workstation
    ];
  };
}
