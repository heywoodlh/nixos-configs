{ pkgs, ... }:

{

  environment.systemPackages = with pkgs.nur.repos.fedx; [
    cockpit-machines
  ];

}
