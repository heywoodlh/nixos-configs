{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 111  2049 4000 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4000 4001  4002 20048 ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /media/home-media	100.64.0.0/10(rw,async,no_root_squash,no_subtree_check,insecure,fsid=1)
    '';
  };
}

