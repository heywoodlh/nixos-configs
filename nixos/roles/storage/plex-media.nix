{ config, pkgs, ... }:

{
  systemd.services.plex-media-movies = {
    enable = true;
    description = "media mergerfs service";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.mergerfs}/bin/mergerfs -f -o cache.files=partial,dropcacheonclose=true,category.create=mfs /media/disk1/movies:/media/disk2/services/media/movies-2 /media/plex/movies";
      ExecStop= "${pkgs.fuse}/bin/fusermount -uz /media/plex/movies";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.services.plex-media-tv = {
    enable = true;
    description = "media mergerfs service";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.mergerfs}/bin/mergerfs -f -o cache.files=partial,dropcacheonclose=true,category.create=mfs /media/disk1/tv:/media/disk2/services/media/tv-2 /media/plex/tv";
      ExecStop= "${pkgs.fuse}/bin/fusermount -uz /media/plex/tv";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
}

