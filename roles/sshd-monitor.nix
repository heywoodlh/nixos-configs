{ config, pkgs, ... }:

let
  sshd-monitor = pkgs.writeScript "sshd-monitor" ''
    #!/usr/bin/env bash
    ### Super simple systemd alerting
    service="sshd.service" 

    ### Pattern to match with `grep -E ...`
    grep_regex_pattern='Failed password|Invalid verification code|Invalid user|Accepted publickey|Accepted password|Accepted keyboard-interactive'
    
    ### Pattern to exclude with `grep -v -E ...`
    grep_exclude_regex_pattern='nagios|Accepted publickey for root from 100.126.114.23'
    
    journalctl -u "''${service}" -n 0 -f | grep --line-buffered -iE "''${grep_regex_pattern}" | grep --line-buffered -ivE "''${grep_exclude_regex_pattern}" | while read line
    do
        echo "''${line}" | gotify push
    done
  '';

  gotify-setup = pkgs.writeScriptBin "gotify-setup" ''
    #!/usr/bin/env bash
    # This script sets up the Gotify configuration file.
    sudo mkdir -p /etc/gotify
    sudo gotify init
  '';

in {
  # Ensure that dependencies are installed
  environment.systemPackages = with pkgs; [ 
    bash
    gotify-cli
    gotify-setup
  ];

  services.openssh.settings.LogLevel = "VERBOSE";
  services.openssh.extraConfig = ''
    SyslogFacility AUTHPRIV
  '';

  systemd.services.sshd-monitor = {
    description = "Monitor SSH daemon";
    path = [ 
      pkgs.bash
      pkgs.gotify-cli 
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
