{ ... }:

{
  imports = [
    ./docker.nix
    ./lima.nix
    ./applications.nix
    ./linux-autostart.nix
    ./marp.nix
    ./1password-docker-helper.nix
    ./darwin-defaults.nix
    ./gnome.nix
    ./cosmic.nix
    ./guake.nix
    ./hyprland.nix
    ./vicinae.nix
    ./onepassword.nix
  ];
}
