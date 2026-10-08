{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  # Enable CUPS to print documents.
  services.printing.drivers = [ pkgs-stable.hplipWithPlugin ];
  hardware.sane.extraBackends = [ pkgs-stable.hplipWithPlugin ];
  systemd.services.configure-hp-officejet-5258 = {
    description = "Configure HP OfficeJet 5258 in CUPS";
    after = [ "network-online.target" "cups.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "45s";
    };
    script = ''
      ${pkgs.cups}/bin/lpadmin -p hp_officejet_5258 -L office -v ipp://192.168.1.31/ipp/print -m everywhere -E
      ${pkgs.cups}/bin/lpadmin -d hp_officejet_5258
    '';
  };

  systemd.timers.configure-hp-officejet-5258 = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnCalendar = "*-*-* *:0/15:00";
      Persistent = true;
      Unit = "configure-hp-officejet-5258.service";
    };
  };
}
