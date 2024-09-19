{ config, ... }:

{
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
  };
  services.tailscale.enable = true;
}
