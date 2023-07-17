{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "drive.heywoodlh.io";
    config = {
      adminpassFile = "/opt/nextcloud/pass.txt";
      adminuser = "heywoodlh";
      extraTrustedDomains = [
        "nix-drive.tailscale"
        "nextcloud"
        "nextcloud.tailscale"
      ];
    };
    appstoreEnable = true;
    autoUpdateApps.enable = true;
    database = {
      createLocally = true;
      dbtype = "pgsql";
    };
    home = "/media/storage/nextcloud";
  };
}
