{ config, pkgs, ... }:

{
  networking.proxy = {
    httpProxy = "http://100.91.102.3:3128";
    httpsProxy = "http://100.91.102.3:3128";
    noProxy = "localhost,127.0.0.1";
  };
}
