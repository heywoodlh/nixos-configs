{ pkgs, ... }:

{
  systemd.services.mergerfs-media-movies = {
    enable = true;
    description = "media mergerfs service";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.mergerfs}/bin/mergerfs -f -o cache.files=partial,dropcacheonclose=true,category.create=mfs /media/disk1/movies:/media/disk2/services/media/movies-2 /media/merged_media/movies";
      ExecStop= "${pkgs.fuse}/bin/fusermount -uz /media/merged_media/movies";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.services.mergerfs-media-tv = {
    enable = true;
    description = "media mergerfs service";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.mergerfs}/bin/mergerfs -f -o cache.files=partial,dropcacheonclose=true,category.create=mfs /media/disk1/tv:/media/disk2/services/media/tv-2 /media/merged_media/tv";
      ExecStop= "${pkgs.fuse}/bin/fusermount -uz /media/merged_media/tv";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };


  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 111  2049 4000 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4000 4001  4002 20048 ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /media/merged_media	100.64.0.0/10(rw,nohide,insecure,no_subtree_check)
    '';
  };
}
