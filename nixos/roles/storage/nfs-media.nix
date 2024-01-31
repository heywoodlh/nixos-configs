{ pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 111  2049 4000 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4000 4001  4002 20048 ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      # k8s-node-1
      /media/home-media      100.122.112.166(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0,anonuid=995,anongid=992)
      # k8s-node-2
      /media/home-media      100.98.186.142(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0,anonuid=995,anongid=992)
      # k8s-node-3
      /media/home-media      100.118.109.137(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0,anonuid=995,anongid=992)

      #nix-nvidia
      /media/home-media      100.108.77.60(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0,anonuid=995,anongid=992)

      # Everyone else (no read/write)
      /media/home-media      100.64.0.0/10(ro,crossmnt,async,no_wdelay,no_root_squash,insecure,no_subtree_check,anonuid=995,anongid=992)
    '';
  };
}
