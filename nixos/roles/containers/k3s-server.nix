{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.system;
  stable-pkgs = nixpkgs-stable.legacyPackages.${system};
in {
  networking.firewall.allowedTCPPorts = [ 6443 ];
  # https://docs.k3s.io/installation/requirements#networking
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 2379 2380 8472 10250 51820 51821 5001 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ]; # for clustering
  services.k3s = {
    package = stable-pkgs.k3s;
    enable = true;
    role = "server";
    clusterInit = true;
  };
  environment.systemPackages = [
    stable-pkgs.k3s
    stable-pkgs.nfs-utils
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
