# Configuration for a non-master Nvidia node
{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  stable-pkgs = nixpkgs-stable.legacyPackages.${system};
in {
  networking.firewall.allowedTCPPorts = [ 6443 ];
  # https://docs.k3s.io/installation/requirements#networking
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 2379 2380 8472 10250 51820 51821 5001 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ]; # for clustering
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };
  services.k3s = {
    package = stable-pkgs.k3s;
    enable = true;
    role = "agent";
    serverAddr = "100.108.77.60";
  };
  environment.systemPackages = [
    stable-pkgs.k3s
    stable-pkgs.nfs-utils
    pkgs.docker # for nvidia GPU
    pkgs.runc # for nvidia GPU
  ];
  systemd.services.k3s.path = with stable-pkgs; [
    ipset
    openiscsi
  ];
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "9192";
    }
  ];
}
