{ config, pkgs, lib, ... }:

let
  script = ''
    #!/usr/bin/env bash

    ${pkgs.git}/bin/git -C /opt/ansible pull origin master || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/ansible /opt/ansible

    ${pkgs.ansible}/bin/ansible-galaxy install -r /opt/ansible/requirements.yml
  '';
  cronJobs = [
  ];
in
{
  systemd.services.update-ansible = {
    description = "Update Ansible repository";
    script = script;
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
  };
  services.cron = {
    enable = true;
    systemCronJobs = [
    "0 * * * * ${pkgs.git}/bin/git -C /opt/ansible pull origin master"
    "15 * * * * ${pkgs.ansible}/bin/ansible-playbook --private-key /root/ansible-ssh -i /opt/ansible/inventory/tailscale.py --limit tag_server /opt/ansible/playbooks/servers/server.yml"
    ];
  };

  environment.systemPackages = with pkgs; [ 
    ansible
    bash
    git
  ];
}
