{ config, ... }:

{
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
  };
}
