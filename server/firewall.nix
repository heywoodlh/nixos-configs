{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 22 ];
}
