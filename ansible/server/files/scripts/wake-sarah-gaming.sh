#!/usr/bin/env bash
set -ex

targetmacs=("54:BF:64:96:06:32" "54:BF:64:96:0B:C6") # I210 enp2s0, I219-LM enp0s31f6
targetip="192.168.1.255"
targetport="9"

for targetmac in "${targetmacs[@]}"; do
  wakeonlan -i $targetip -p $targetport $targetmac
done
