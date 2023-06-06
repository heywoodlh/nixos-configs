{ config, pkgs, ... }:

{
  services.syslog-ng = {
    enable = true;
    extraConfig = ''
      destination nix_nvidia {
        syslog("nix-nvidia.tailscale" transport("tcp") port("1514"));
      };

      filter f_ssh {
        program("sshd");
      };

      log {
        source(system);
        filter(f_ssh);
        destination(nix_nvidia);
      };

      source system {
        system();
        internal();
      };
    '';
  };
}
