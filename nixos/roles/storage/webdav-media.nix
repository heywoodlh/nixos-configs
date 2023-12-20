{ pkgs, ... }:

let
  webdav = {
    port = 7080;
    dir = "/media/home-media";
    user = "media";
    group = "media";
  };
in {
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ webdav.port ];
  };

  services.webdav = {
    enable = true;
    user = webdav.user;
    group = webdav.group;
    settings = {
      address = "0.0.0.0";
      port = webdav.port;
      scope = "${webdav.dir}";
      auth = false;
      modify = false;
    };
  };
}
