{ config, pkgs, ... }:

{
  time.timeZone = "America/Denver";

  networking = {
    hostName = "nix-server";
    useDHCP = true;
    enableIPv6 = false;
    usePredictableInterfaceNames = true;
    dhcpcd.persistent = true;
  };
}

#let
  #hostname = "nix-server";
  #interface = "enp2s0";
  #default_gateway = "192.168.1.1"
  #network = "192.168.1.0";
  #ip_address =  "192.168.1.5";
  #prefix_length = "24";
  #nameservers = "1.1.1.1";
#in {
  #networking = {
  #  hostName = "${hostname}"; 
  #  defaultGateway = "${default_gateway}";
  #  useDHCP = false;
  #  enableIPv6 = false;
  #  usePredictableInterfaceNames = true;
  #  interfaces.${interface} = {
  #    ipv4.addresses = [ {
  #      address = "${ip_address}";
  #	prefixLength = ${prefix_length};
  #    } ];
  #  }; 
  #};
#}
