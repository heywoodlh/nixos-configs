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

ansible-galaxy install -r /ansible/requirements.yml

for target in "${targets[@]}"
do
    if [[ "${target}" == "server" ]]
    then
        # server build
        ansible-playbook --connection=local /ansible/server/standalone.yml || exit 1
        printf "server playbooks completed"
    fi
    if [[ "${target}" == "workstation" ]]
    then
        # workstation build
        ansible-playbook --connection=local /ansible/workstation/workstation.yml || exit 2
        printf "workstation playbooks completed"
    fi
done
