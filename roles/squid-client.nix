{ config, pkgs, ... }:

{
  networking.proxy = {
    httpProxy = "http://ct-1.tailscale:3128";
    httpsProxy = "http://ct-1.tailscale:3128";
    noProxy = "localhost,127.0.0.1";
  };
}
