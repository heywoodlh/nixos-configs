{ config, pkgs, lib, nixos-apple-silicon, ... }:

{
  imports = [
    (nixos-apple-silicon + "/apple-silicon-support")
  ];
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  nixpkgs.config = {
    allowUnsupportedSystem = true;
  };

  hardware.asahi.enable = true;

  environment.sessionVariables = rec {
    COGL_DEBUG = "sync-frame";
    CLUTTER_PAINT = "disable-dynamic-max-render-time";
  };

  boot.extraModprobeConfig = ''
    options hid_apple swap_fn_leftctrl=1
  '';

  nix.settings = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };
}
