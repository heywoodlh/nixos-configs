{ config, pkgs, ... }:

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

    settings.default_phone_region = "US";
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
    maxUploadSize = "40G";
    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };
  };
  services.postgresqlBackup = {
    enable = true;
    startAt = "*-*-* 01:15:00";
    location = "/opt/nextcloud/db-backups";
  };
}
