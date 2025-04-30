{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.system;
  stable-pkgs = nixpkgs-stable.legacyPackages.${system};
in {
  services.monit = {
    enable = true;
    config = ''
      set daemon 30
      set log /var/log/monit.log

      check device var with path /
        if SPACE usage > 80% then alert
    '';
  };
  services.syslog-ng = {
    enable = true;
    package = stable-pkgs.syslogng;
    extraConfig = ''
      destination syslog_ng {
        syslog("syslog.barn-banana.ts.net" transport("tcp") port("1514"));
      };

      filter f_ssh {
        program("sshd");
      };

      log {
        source(system);
        source(monit);
        filter(f_ssh);
        destination(syslog_ng);
      };

      source monit {
        file("/var/log/monit.log" follow-freq(1) flags(no-parse));
      };

      source system {
        system();
        internal();
      };
    '';
  };
}
