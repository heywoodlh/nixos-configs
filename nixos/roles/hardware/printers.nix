{ config, pkgs, nixpkgs-stable, ... }:

let
  system = pkgs.system;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  # Enable CUPS to print documents.
  services.printing.drivers = [ pkgs-stable.hplipWithPlugin ];
  hardware.sane.extraBackends = [ pkgs-stable.hplipWithPlugin ];
  hardware.printers = {
    ensurePrinters = [
      {
        name = "hp_officejet_5258";
        location = "office";
        deviceUri = "ipp://192.168.50.122/ipp/print";
        model = "everywhere";
      }
    ];
    ensureDefaultPrinter = "hp_officejet_5258";
  };
}
