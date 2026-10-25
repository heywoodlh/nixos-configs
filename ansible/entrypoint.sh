#!/usr/bin/env bash
PATH="/root/.local/bin:/usr/bin:/usr/local/bin:$PATH"

set -ex

targets=("server" "workstation")
if [[ -n "$1" ]]
then
    if [[ "$1" == "server" || "$1" == "workstation" ]]
    then
        printf '%s\0' "${targets[@]}" | grep -q -F -x -z -- "$1" && targets=("$1")
    else
        printf "Invalid target: ${1}"
        exit 3
    fi
fi

ansible-galaxy install -r /nixos-configs/ansible/requirements.yml

verify_profiles() {
    if [[ -e /usr/bin/ubios-udapi-server ]]
    then
        test ! -e /nix
        crontab -l | grep -Fx 'CRON_TZ="America/Denver"'
        crontab -l | grep -Fx "#Ansible: weekly router reboot"
        crontab -l | grep -Fx "30 3 * * 1 /usr/bin/systemctl reboot"
        dpkg-query -W -f='${Status}\n' libpam-duo | grep -Fx 'install ok installed'
        test "$(stat -c '%a:%U:%G' /etc/duo/pam_duo.conf)" = '600:root:root'
        grep -Fx 'auth requisite pam_duo.so' /etc/pam.d/sshd
        grep -Fx 'auth sufficient pam_permit.so' /etc/pam.d/sshd
        sshd -T | grep -Fx 'authenticationmethods publickey keyboard-interactive'
        return
    fi

    NIX_BIN=/nix/var/nix/profiles/default/bin/nix
    if [[ ! -x "$NIX_BIN" ]]
    then
        NIX_BIN=/home/heywoodlh/.nix-profile/bin/nix
    fi

    test -x "$NIX_BIN"
    "$NIX_BIN" --extra-experimental-features 'nix-command flakes' flake --help >/dev/null
    test -L /home/heywoodlh/.local/state/nix/profiles/home-manager
    test -x /home/heywoodlh/.local/state/nix/profiles/home-manager/activate
}

for target in "${targets[@]}"
do
    if [[ "${target}" == "server" ]]
    then
        # server build
        ansible-playbook --connection=local --extra-vars nixos_configs_root=path:/nixos-configs /nixos-configs/ansible/server/standalone.yml || exit 1
        verify_profiles
        if [[ -e /usr/bin/ubios-udapi-server ]]
        then
            # Verify a converged UniFi playbook recovers an independently
            # failed syslog-ng service, not merely a changed configuration.
            systemctl stop syslog-ng.service
            ansible-playbook --connection=local --extra-vars nixos_configs_root=path:/nixos-configs /nixos-configs/ansible/server/standalone.yml || exit 1
            systemctl is-active --quiet syslog-ng.service
        fi
        printf "server playbooks completed"
    fi
    if [[ "${target}" == "workstation" ]]
    then
        # workstation build
        ansible-playbook --connection=local --extra-vars nixos_configs_root=path:/nixos-configs /nixos-configs/ansible/workstation/workstation.yml || exit 2
        verify_profiles
        printf "workstation playbooks completed"
    fi
done
