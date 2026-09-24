#!/usr/bin/env bash
set -ex

targetmac="10:FF:E0:4E:A7:A9" # corsair
targetip="192.168.1.255"
targetport="9"

wakeonlan -i $targetip -p $targetport $targetmac
