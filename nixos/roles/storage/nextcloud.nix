{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 80 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "drive.heywoodlh.io";
    config = {
      adminpassFile = "/opt/nextcloud/pass.txt";
      adminuser = "heywoodlh";
      dbtype = "pgsql";
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
    };
    home = "/media/storage/nextcloud";
  };
}
