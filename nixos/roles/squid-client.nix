{ config, pkgs, ... }:

{
  networking.proxy = {
    httpProxy = "http://100.113.9.57:3128";
    httpsProxy = "http://100.113.9.57:3128";
    noProxy = "localhost,127.0.0.1,docker.io,github.com";
  };
}
