{ config, pkgs, lib, ... }:

let
  script = ''
    #!/usr/bin/env bash

    ${pkgs.git}/bin/git -C /opt/ansible pull origin master || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/ansible /opt/ansible

    ${pkgs.ansible}/bin/ansible-galaxy install -r /opt/ansible/requirements.yml
    ${pkgs.ansible}/bin/ansible-playbook /opt/ansible/setup.yml
  '';
  cronJobs = [
    {
      name = "update-ansible-inventory";
      command = "${pkgs.git}/bin/git -C /opt/ansible pull origin master";
      schedule = "0 * * * *";
      user = "root";
    }
    {
      name = "deploy-ansible-server-playbook";
      command = "${pkgs.ansible}/bin/ansible-playbook --private-key /root/ansible-ssh -i /opt/ansible/inventory/tailscale.py tag_server /opt/ansible/playbooks/servers/server.yml";
      schedule = "15 * * * *";
      user = "root";
    }
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
    jobs = cronJobs;
  };

  environment.systemPackages = with pkgs; [ 
    ansible
    bash
    git
  ];
}
