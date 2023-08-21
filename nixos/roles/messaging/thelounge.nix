{ pkgs, config, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    2001
  ];
  services.thelounge = {
    enable = true;
    public = false;
    port = 2001;
    plugins = with pkgs; [
      nodePackages.thelounge-theme-nord
    ];
    extraConfig = {
      reverseProxy = true;
      host = "nix-media.tailscale";
    };
  };
}
