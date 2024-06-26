{ config, pkgs, lib, ... }:

{
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = lib.mkForce "enp6s18";
  networking.nat.internalInterfaces = lib.mkForce [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51821 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51821;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp6s18 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o enp6s18 -j MASQUERADE
      '';
      privateKeyFile = "/root/wireguard-keys/private";
      peers = [
        { # Paul Macbook
          publicKey = "XOelNu3deGab7HSepPfjAUxYkbauxwBPTMHbBsVTmB0=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        { # Paul Mac Studio
          publicKey = "WkhUOnfoHkFBFbSJoKVc99cVm3+pTrI5/PQzMAb4nWM=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };
}
