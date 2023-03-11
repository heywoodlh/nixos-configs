{ config, pkgs, ... }:

{
  networking.proxy = {
    httpProxy = "http://10.50.50.1:3128";
    httpsProxy = "http://10.50.50.1:3128";
    noProxy = "localhost,127.0.0.1";
  };
}
