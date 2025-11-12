#!/usr/bin/env bash
export LC_ALL="C.UTF-8"
dir=$(dirname -- "$( readlink -f -- "$0"; )";)
operating_systems=("ubuntu" "debian" "unifi" "alpine")
# If AMD64, also test Arch Linux
[[ $(arch) == "x86_64" ]] && operating_systems+=("archlinux")

# If argument provided, test single OS
if [[ -n "$1" ]]
then
  printf '%s\0' "${operating_systems[@]}" | grep -q -F -x -z -- "$1" && operating_systems=("$1")
fi

targets=("server" "workstation")
if [[ -n "$2" ]]
then
  if [[ "$2" == "server" || "$2" == "workstation" ]]
  then
    printf '%s\0' "${targets[@]}" | grep -q -F -x -z -- "$2" && targets=("$2")
  else
    printf "Invalid target: ${2}"
    exit 3
  fi
fi

docker_run_args=""

echo "Operating systems that will be tested: ${operating_systems[@]}"
echo "Targets that will be tested: ${targets[@]}"
for os in "${operating_systems[@]}"
do
  echo "Testing: ${os}"
  set -ex
  docker build -q -t ansible-${os}-test -f ${dir}/Dockerfile --target ${os}-test ${dir} || printf "Error occurred on operating system: ${os}"
  mkdir -p /tmp/ansible
  echo "" > ${dir}/.ansible.log
  for target in "${targets[@]}"
  do
    # Skip specific combinations
    if [[ "${os}" == "unifi" && "${target}" == "workstation" ]]
    then
      echo "Skipping unifi+workstation"
    else
      echo "Testing: ${target}"
      if [[ "${os}" == "unifi" ]]
      then
        docker run -it --hostname=spencer-router --rm -v /tmp/.ansible:/root/.ansible --privileged ansible-${os}-test ${target}
      elif [[ "${os}" == "ubuntu" ]]
      then
        docker run -it --hostname=cloud --rm -v "${dir}/.ansible.log:/ansible.log" -v /tmp/.ansible:/root/.ansible --privileged ansible-${os}-test ${target}
      else
          docker run -it --rm -v "${dir}/.ansible.log:/ansible.log" -v /tmp/.ansible:/root/.ansible --privileged ansible-${os}-test ${target}
      fi
    fi
  done
done
