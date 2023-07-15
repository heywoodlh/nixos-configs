{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      25
      143
      8080
    ];
  };

  # Remember to run the following command wto initially setup the bridge:
  # docker run -it --rm --name=protonmail-bridge -v /opt/protonmail-bridge/data:/root docker.io/shenxn/protonmail-bridge:${image_tag} init
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      protonmailbridge = {
        image = "docker.io/shenxn/protonmail-bridge:3.0.21-1";
        autoStart = true;
        volumes = [
          "/opt/protonmail-bridge/data:/root"
        ];
        ports = [
          "25:25"
          "143:143"
          "8080:8080"
        ];
      };
    };
  };
}
