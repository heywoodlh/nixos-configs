#! /usr/bin/env nix-shell
#! nix-shell -i bash -p deploy-rs nix git

host=$1

# Get directories
cur_dir=$(pwd)
script_dir=$(dirname "${BASH_SOURCE[0]}")

# Check if host is given
if [[ -z "$host" ]]
then
    echo "Usage: $0 <host>"
    # Get hosts from flake.nix
    grep "hostname = " $script_dir/flake.nix | cut -d "=" -f 2 | cut -d "." -f 1 | tr -d "[:blank:]" | tr -d '"'
    exit 1
fi

cd $script_dir
nix flake update && git add flake.lock
deploy --remote-build --skip-checks .#$host
cd $cur_dir
