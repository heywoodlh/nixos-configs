{ config, pkgs, ... }:

let
  tarsnapSetup = pkgs.writeShellScriptBin "tarsnap-setup.sh" ''
    sudo tarsnap-keygen \
      --keyfile /root/tarsnap.key \
      --user tarsnap@heywoodlh.io \
      --machine $(hostname)
  '';
  tarsnapList = pkgs.writeShellScriptBin "tarsnap-list-archives.sh" ''
    sudo tarsnap --list-archives --keyfile /root/tarsnap.key --cachedir /var/cache/tarsnap/nixos-archive
  '';
in {
  environment.systemPackages = with pkgs; [
    tarsnap
    tarsnapList
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
