#!/usr/bin/env bash
export LC_ALL="C.UTF-8"
dir=$(dirname -- "$( readlink -f -- "$0"; )";)
operating_systems=("ubuntu" "debian" "alpine")
# If AMD64, also test Arch Linux
[[ $(arch) == "x86_64" ]] && operating_systems+=("archlinux")

# If argument provided, test single OS
if [[ -n "$1" ]]
then
    printf '%s\0' "${operating_systems[@]}" | grep -q -F -x -z -- "$1" && operating_systems=("$1")
fi

echo "Operating systems that will be tested: ${operating_systems[@]}"
for os in "${operating_systems[@]}"
do
  echo "Testing: ${os}"
  set -ex
  docker build -q -t ${os}-server -f ${dir}/../docker/Dockerfile --target ${os}-server ${dir}/.. || printf "Error occurred on operating system: ${os}"
  docker build -q -t ${os}-desktop -f ${dir}/../docker/Dockerfile --target ${os}-desktop ${dir}/.. || printf "Error occurred on operating system: ${os}"
  # If os is "debian" or "ubuntu" then include ${os}-debs target
  if [[ ${os} == "debian" || ${os} == "ubuntu" ]]
  then
    [[ $(arch) == "x86_64" ]] && docker build -q -t ${os}-debs -f ${dir}/../docker/Dockerfile --target ${os}-debs ${dir}/.. || printf "Error occurred on operating system: ${os}"
  fi
  #mkdir -p /tmp/ansible
  docker run -it --rm -v /tmp/.ansible:/root/.ansible --privileged ${os}-server
  docker run -it --rm -v /tmp/.ansible:/root/.ansible --privileged ${os}-desktop
done
