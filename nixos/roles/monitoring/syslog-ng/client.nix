{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  stable-pkgs = nixpkgs-stable.legacyPackages.${system};
in {
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * *      root    echo '' > /var/log/audit/audit.log"
    ];
  };
  services.monit = {
    enable = true;
    config = ''
      set daemon 30
      set log /var/log/monit.log

      check device var with path /
        if SPACE usage > 80% then alert
    '';
  };
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    rules = [
      "-a exit,always -F arch=b64 -S execve"
    ];
  };
  services.syslog-ng = {
    enable = true;
    package = stable-pkgs.syslogng;
    extraConfig = ''
      destination syslog_ng {
        syslog("syslog.barn-banana.ts.net" transport("tcp") port("1514"));
      };

      source system {
        system();
        internal();
      };

      filter f_ssh {
        program("sshd");
      };

      source monit {
        file("/var/log/monit.log" follow-freq(1) flags(no-parse));
      };

      source audit {
        file("/var/log/audit/audit.log");
      };

      log {
        source(system);
        filter(f_ssh);
        destination(syslog_ng);
      };

      log {
        source(audit);
        destination(syslog_ng);
      };

      log {
        source(monit);
        destination(syslog_ng);
      };
    '';
  };
}
