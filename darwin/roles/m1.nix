{ config, pkgs, lib, ... }:

{
  # Include extra architecture 
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
  '';
}
