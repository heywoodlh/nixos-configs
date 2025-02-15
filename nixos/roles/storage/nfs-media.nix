{ pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 111  2049 4000 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4000 4001  4002 20048 ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      #tailnet
      /media/home-media      100.64.0.0/10(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0,anonuid=995,anongid=992)
    '';
  };
}
