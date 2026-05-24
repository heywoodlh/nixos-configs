{ ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  heywoodlh.nixos = {
    steam-deck = {
      enable = true;
    };
    gaming = {
      enable = true;
    };
  };
}
