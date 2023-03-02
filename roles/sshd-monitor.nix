{ config, pkgs, ... }:

let
  sshd-monitor = pkgs.writeScript "sshd-monitor" ''
    #!/usr/bin/env bash
    # This script monitors the SSH daemon and takes action if it is not running.

    export PATH=/run/current-system/sw/bin/:$PATH

    ### Super simple systemd alerting
    
    ### Service name
    service="sshd.service"
    
    ### Pattern to match with `grep -E ...`
    grep_regex_pattern='Failed password|Invalid verification code|Invalid user|Accepted publickey|Accepted password|Accepted keyboard-interactive'
    
    ### Pattern to exclude with `grep -v -E ...`
    grep_exclude_regex_pattern='nagios'
    
    journalctl -u ${service} -n 0 -f | grep --line-buffered -iE "${grep_regex_pattern}" | grep --line-buffered -ivE "${grep_exclude_regex_pattern}" | while read line
    do
        echo "${line}" | gotify push
    done
  '';
in {
  # Ensure that dependencies are installed
  environment.systemPackages = with pkgs; [ 
    gotify-cli 
  ];

  systemd.services.sshd-monitor = {
    description = "Monitor SSH daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sshd-monitor}";
      Restart = "on-failure";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
