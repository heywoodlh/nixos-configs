{ config, pkgs, lib, ... }:

let
  script = ''
    #!/usr/bin/env bash

    ${pkgs.git}/bin/git -C /opt/ansible pull origin master || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/ansible /opt/ansible

    ${pkgs.ansible}/bin/ansible-galaxy install -r /opt/ansible/requirements.yml
  '';
  cronJobs = [
  ];
  server-update = pkgs.writeShellScriptBin "server-update" ''
    #!/usr/bin/env bash
    /run/wrappers/bin/sudo ${pkgs.ansible}/bin/ansible --private-key /root/ansible-ssh -i /opt/ansible/inventory/tailscale.py tag_server -m ansible.builtin.command -a 'ansible-pull -c local -U https://github.com/heywoodlh/ansible playbooks/servers/server.yml'
  '';
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
    "0 4 * * Sun ${pkgs.ansible}/bin/ansible --private-key /root/ansible-ssh -i /opt/ansible/inventory/tailscale.py tag_server -m ansible.builtin.command -a 'ansible-pull -c local -U https://github.com/heywoodlh/ansible playbooks/servers/server.yml'"
    ];
  };

  environment.systemPackages = with pkgs; [
    ansible
    bash
    git
    server-update
  ];

  environment.etc."ansible/ansible.cfg" = {
    enable = true;
    text = import ansible/ansible.cfg.nix;
  };
}
