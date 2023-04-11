{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    interfaceName = "tailscale0";
  };
}
