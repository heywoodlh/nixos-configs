{ config, ... }:

{
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
  };
  # Use Tailscale app for better compatibility with airports, etc.
  #services.tailscale = {
  #  enable = true;
  #  overrideLocalDns = true;
  #};
}
