{ config, pkgs, ... }:

{
  users.users.media = {
    group = "media";
    isSystemUser = true;
    uid = 995;
  };

  fileSystems."/media/services" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
  };

  fileSystems."/media/movies-1" = {
    device = "10.0.50.50:/media/disk1/movies";
    fsType = "nfs";
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
  };

  fileSystems."/media/tv-1" = {
    device = "10.0.50.50:/media/disk1/tv";
    fsType = "nfs";
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
  };
}
