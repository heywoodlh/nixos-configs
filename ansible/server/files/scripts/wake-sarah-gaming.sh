#!/usr/bin/env bash
set -ex

targetmac="54:BF:64:96:06:32" # precision
targetip="192.168.1.255"
targetport="9"

wakeonlan -i $targetip -p $targetport $targetmac
