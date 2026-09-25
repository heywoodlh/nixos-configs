#!/usr/bin/env bash

disk="$1"

# If no args, then exit with usage
if [ "$#" -ne 1 ]
then
    echo "Usage: $0 <disk>"
    exit 1
fi

# Check if /dev/sdb has been added to ceph cluster
microceph disk list --json | jq ".ConfiguredDisks" | grep -q "${disk}"
status="$?"

if [ "$status" -eq 0 ]
then
    echo "$(date): Disk ${disk} has already added to ceph cluster. Exiting" | tee /tmp/add-ceph.log
else
    echo "$(date): Disk has not been added to ceph cluster. Adding now" | tee /tmp/add-ceph.log
    microceph disk add "${disk}" --wipe
fi
