#!/usr/bin/env bash

# Get list of files, minus the script itself
script_dir="$(echo "$(dirname $0)")"
files="linux.sh README.md"

username="$(op-wrapper.sh item get "3qaxsqbv5dski4wqswxapc7qoi" --fields label=username)"
password="$(op-wrapper.sh item get "3qaxsqbv5dski4wqswxapc7qoi" --fields label=webdav --reveal)"

endpoint="https://myfiles.fastmail.com/files/scripts"

[[ -z "${username}" ]] && echo "Username not found" && exit 1
[[ -z "${password}" ]] && echo "Password not found" && exit 1

for file in ${files}
do

    echo "Uploading ${file} to ${endpoint}/${file}"
    curl --user "${username}:${password}" -T "${script_dir}/${file}" "${endpoint}/${file}"
done
