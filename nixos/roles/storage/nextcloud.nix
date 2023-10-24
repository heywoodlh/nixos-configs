{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 80 ];

  services.nextcloud = {
    enable = true;
    # Caching
    configureRedis = true;
    hostName = "drive.heywoodlh.io";
    config = {
      dbtype = "pgsql";
      adminpassFile = "/opt/nextcloud/pass.txt";
      adminuser = "heywoodlh";
      extraTrustedDomains = [
        "drive.heywoodlh.io"
        "nix-drive.tailscale"
        "nextcloud"
        "nextcloud.tailscale"
      ];
    };
    appstoreEnable = true;
    autoUpdateApps.enable = true;
    database = {
      createLocally = true;
    };
    home = "/media/storage/nextcloud";
    phpOptions = {
      upload_max_filesize = "40G";
      post_max_size = "40G";
    };
  };
}
