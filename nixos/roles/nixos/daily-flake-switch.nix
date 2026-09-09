{ pkgs, ... }:

{
  systemd.services.nixos-flake-switch = {
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "git+https://tangled.org/heywoodlh.io/nixos-configs#$(hostname)"
    '';
  };

  systemd.timers.nixos-flake-switch = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00 America/Denver";
      Persistent = true;
    };
  };
}
