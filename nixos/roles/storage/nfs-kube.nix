{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 111  2049 4000 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4000 4001  4002 20048 ];
  };
  services.nfs.server = {
    enable = true;
    exports = ''
      # k8s-node-1
      /media/virtual-machines/kube      100.122.112.166(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0)
      # k8s-node-2
      /media/virtual-machines/kube      100.98.186.142(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0)
      # k8s-node-3
      /media/virtual-machines/kube      100.118.109.137(rw,crossmnt,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0)
    '';
  };
}
