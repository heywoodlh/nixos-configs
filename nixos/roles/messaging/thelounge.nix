{ pkgs, config, ... }:

{
  services.thelounge = {
    enable = true;
    public = false;
    port = 8080;
    plugins = with pkgs; [
      nodePackages.thelounge-theme-nord
    ];
  };
}
