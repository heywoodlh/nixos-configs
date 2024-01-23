{ config, pkgs, ... }:

{
  services.syslog-ng = {
    enable = true;
    extraConfig = ''
      destination nix_nvidia_syslog_ng {
        syslog("nix-nvidia.barn-banana.ts.net" transport("tcp") port("1514"));
      };
      destination nix_nvidia_graylog {
        syslog("nix-nvidia.barn-banana.ts.net" transport("tcp") port("514"));
      };

      filter f_ssh {
        program("sshd");
      };

      log {
        source(system);
        source(monit);
        filter(f_ssh);
        destination(nix_nvidia_syslog_ng);
        destination(nix_nvidia_graylog);
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
