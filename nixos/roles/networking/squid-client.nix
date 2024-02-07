{ config, pkgs, ... }:

{
  networking.proxy = {
    default = "http://squid.barn-banana.ts.net:3128";
    httpProxy = "http://squid.barn-banana.ts.net:3128";
    httpsProxy = "http://squid.barn-banana.ts.net:3128";
    noProxy = "localhost,127.0.0.1,docker.io,*.docker.io,*.docker.com,*.nixos.org,github.com,githubusercontent.com,ghcr.io,*.ghcr.io,*.tailscale";
  };
}
