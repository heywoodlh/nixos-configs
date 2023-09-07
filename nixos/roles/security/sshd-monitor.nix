{ config, pkgs, ... }:

let
  sshd-monitor = pkgs.writeScript "sshd-monitor" ''
    #!/usr/bin/env bash
    ### Super simple systemd alerting
    service="sshd.service"

    ### Pattern to match with `grep -E ...`
    grep_regex_pattern='Failed password|Invalid verification code|Invalid user|Accepted publickey|Accepted password|Accepted keyboard-interactive'

    ### Pattern to exclude with `grep -v -E ...`
    grep_exclude_regex_pattern='root from 100.126.114.23|root from 100.98.176.50'

    journalctl -u "''${service}" -n 0 -f | grep --line-buffered -iE "''${grep_regex_pattern}" | grep --line-buffered -ivE "''${grep_exclude_regex_pattern}" | while read line
    do
        # Using Cloudflare Zero Trust to restrict access to this endpoint
        ${pkgs.curl}/bin/curl -d "''${line}" http://nix-ext-net.tailscale:8082/ssh-notifications
    done
  '';

in {
  services.openssh.settings.LogLevel = "VERBOSE";
  services.openssh.extraConfig = ''
    SyslogFacility AUTHPRIV
  '';

  systemd.services.sshd-monitor = {
    description = "Monitor SSH daemon";
    path = [
      pkgs.bash
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sshd-monitor}";
      Restart = "on-failure";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
