{ config, pkgs, ... }:

let
  tarsnapSetup = pkgs.writeShellScriptBin "tarsnap-setup.sh" ''
    sudo tarsnap-keygen \
      --keyfile /root/tarsnap.key \
      --user tarsnap@heywoodlh.io \
      --machine $(hostname)
  '';
in {
  environment.systemPackages = with pkgs; [
    tarsnap
    tarsnapSetup
  ];
  services.tarsnap = {
    enable = true;
    package = pkgs.tarsnap;
    keyfile = "/root/tarsnap.key";
    archives = {
      nixos =  {
        cachedir = "/var/cache/tarsnap/nixos-archive";
        directories = [
          "/etc"
          "/opt"
          "/root"
          "/home"
        ];
        excludes = [
          "tarsnap.key"
          "shadow"
          "passwd"
          "nixpkgs"
          "containerd"
        ];
      };
    };
  };
}
