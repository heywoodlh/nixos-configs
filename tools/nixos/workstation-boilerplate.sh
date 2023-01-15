#!/usr/bin/env bash

# This script creates a very basic configuration.nix that imports every .nix file in the target directory
# It assumes there is not already a configuration.nix file in the target directory

# Usage: workstation-boilerplate.sh /path/to/target/directory
# Example: workstation-boilerplate.sh /etc/nixos

# Make sure $1 is set and is a directory
if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: workstation-boilerplate.sh /path/to/target/directory <nixos-version>"
    exit 1
else
    target_dir="$1"
fi

# Make sure $2 is set and is a valid NixOS version
if [ -z "$2" ]; then
	echo "Usage: workstation-boilerplate.sh /path/to/target/directory <nixos-version>"
	exit 1
else
	nixos_version="$2"
fi

# Make sure there is not already a configuration.nix file in the target directory
if [ -f "$target_dir/configuration.nix" ]; then
	echo "There is already a configuration.nix file in $target_dir"
	exit 1
fi

# Grab a list of all .nix files in the target directory, space separated without the target directory path
nix_files=$(find "$target_dir" -maxdepth 1 -type f -name "*.nix" -printf "./%f ")

# Create a basic configuration.nix file
cat > "$target_dir/configuration.nix" << EOF
{ lib, config, pkgs, ... }:

{
  imports = [ $nix_files ];

  system.stateVersion = "$nixos_version";

  boot = lib.mkForce { };
  environment.systemPackages = lib.mkForce [ ];
}
EOF
