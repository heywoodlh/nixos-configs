{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.moonlight;
  #moonlight-qt-unstable = pkgs.moonlight-qt.overrideAttrs (oldAttrs: {
  #  version = "unstable";
  #  src = pkgs.fetchFromGitHub {
  #    owner = "moonlight-stream";
  #    repo = "moonlight-qt";
  #    rev = "78bc2141f69c512fda23197456f4869e4961c081";
  #    hash = "sha256-360bl9hsqpUs/tmTo3HA89GNJz6Tf8MJUcfYQAqigmY=";
  #    fetchSubmodules = true;
  #  };
  #  # Remove patches that may not apply to the current rev
  #  patches = [];
  #});
in {
  options.heywoodlh.nixos.moonlight = {
    enable = mkOption {
      default = false;
      description = "Install Moonlight-QT Flatpak for.";
      type = bool;
    };
    user = mkOption {
      default = "heywoodlh";
      description = "User to install Moonlight-QT Flatpak for.";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = let
      moonlight-qt-unstable = pkgs.writeShellScriptBin "moonlight" ''
        ${pkgs.flatpak}/bin/flatpak --user run com.moonlight_stream.Moonlight
      '';
    in [
      moonlight-qt-unstable
    ];
    home-manager.users.${cfg.user}.home.activation.moonlight-qt-unstable =''
      ${pkgs.flatpak}/bin/flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
      ${pkgs.flatpak}/bin/flatpak install -y --noninteractive --user flathub com.moonlight_stream.Moonlight///master
    '';
  };
}
