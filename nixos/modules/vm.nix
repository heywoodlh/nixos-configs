{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.vm;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.heywoodlh.vm = mkOption {
    default = false;
    description = "Enable heywoodlh virtual machine configuration.";
    type = bool;
  };

  config = mkIf cfg {
    heywoodlh.workstation = true;

    networking = optionalAttrs (config.heywoodlh.defaults.networkmanager){
      networkmanager =  {
        insertNameservers =  [
          "100.100.100.100"
        ];
      };
      resolvconf.extraConfig = ''
        prepend_nameservers=100.100.100.100
        search_domains=barn-banana.ts.net
      '';
    };

    # Disable sound
    services.pipewire = {
      enable = mkForce false;
      alsa.enable = mkForce false;
      alsa.support32Bit = mkForce false;
      pulse.enable = mkForce false;
    };

    # Disable bluetooth
    hardware.bluetooth.enable = mkForce false;

    # Enable SPICE guest agent
    services.spice-vdagentd.enable = true;
  };
}
