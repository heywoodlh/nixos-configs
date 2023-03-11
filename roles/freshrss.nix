{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
  ];

  users.users.media = {
    group = "media";
    isSystemUser = true;
    uid = 1050;
  };

  fileSystems."/media/services" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
  };

  services.freshrss = {
    enable = true;
    dataDir = "/media/services/freshrss";
    user = "media";
  };
}
