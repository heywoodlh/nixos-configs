{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.system;
  stable-pkgs = nixpkgs-stable.legacyPackages.${system};
in {
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s = {
    package = stable-pkgs.k3s;
    enable = true;
    role = "server";
  };
  environment.systemPackages = [ stable-pkgs.k3s ];
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
