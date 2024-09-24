{ config, pkgs, ... }:

{
  imports = [
    ./sketchybar.nix
    ./yabai.nix
    ./stage-manager.nix
  ];
}
