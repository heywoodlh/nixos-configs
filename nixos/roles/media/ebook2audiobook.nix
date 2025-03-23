{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    7860
  ];

  virtualisation.oci-containers = let
    resolvConf = pkgs.writeText "resolv.conf" ''
      nameserver 1.1.1.1
      nameserver 1.0.0.1
    '';
  in {
    backend = "docker";
    containers = {
      ebook2audiobook = {
        image = "docker.io/athomasson2/ebook2audiobook:cuda11";
        autoStart = true;
        ports = [
          "7860:7860"
        ];
        volumes = [
          "/tmp:/in"
          "/media/home-media/disk2/books/:/out"
          "/etc/localtime:/etc/localtime:ro"
          "${resolvConf}:/etc/resolv.conf:ro"
        ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };
    };
  };
}
