{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    3000
  ];

  services.hydra = {
    enable = true;
    hydraURL = "http://0.0.0.0:3000";
    notificationSender = "hydra@heywoodlh.io";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  nix = {
    buildMachines = [
      {
        hostName = "nixos-x86_64";
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 8;
      }
    ];
  };
}
