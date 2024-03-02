{ config, pkgs, lib, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 80 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    # Caching
    configureRedis = true;
    hostName = "drive.heywoodlh.io";
    config = {
      dbtype = "pgsql";
      adminpassFile = "/opt/nextcloud/pass.txt";
      adminuser = "heywoodlh";
    };

    settings.trusted_domains = [
      "drive.heywoodlh.io"
      "nix-drive"
      "nextcloud"
    ];
    appstoreEnable = true;
    autoUpdateApps.enable = true;
    database = {
      createLocally = true;
    };
    home = "/media/storage/nextcloud";
    phpOptions = {
      upload_max_filesize = lib.mkForce "40G";
      post_max_size = lib.mkForce "40G";
    };
  };
}
