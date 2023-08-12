{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.sunshine;
in
{
  options = {

    services.sunshine = {
      enable = mkEnableOption (mdDoc "Sunshine");
    };
  };

  config = mkIf config.services.sunshine.enable {

    boot = { kernelModules = [ "uinput" ]; };
    services = {
      udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
      '';
    };

    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };

    systemd.user.services.sunshine = {
      description = "sunshine";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
      };
    };

    services.avahi = {
      enable = true;
      reflector = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
        workstation = true;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        47984
        47989
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };
  };
}
