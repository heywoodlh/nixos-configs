{ config, lib, ... }:

with lib;
with lib.types;

let
  userType = submodule {
    options = {
      name = mkOption {
        default = "heywoodlh";
        description = "Username for heywoodlh defaults.";
        type = str;
      };
      description = mkOption {
        default = "Spencer Heywood";
        description = "Full name of user for heywoodlh defaults.";
        type = str;
      };
      uid = mkOption {
        default = 1000;
        description = "UID for user for heywoodlh defaults.";
        type = int;
      };
      homeDir = mkOption {
        default = "/home/${config.heywoodlh.defaults.user.name}";
        description = "Home directory for user for heywoodlh defaults.";
        type = path;
      };
      icon = mkOption {
        default = "";
        description = "Icon for user (unused on MacOS).";
        type = str;
      };
    };
  };
in {
  options.heywoodlh.defaults = {
    enable = mkOption {
      default = false;
      description = "Enable heywoodlh defaults.";
      type = bool;
    };
    user = mkOption {
      description = "User for heywoodlh configuration.";
      type = userType;
    };
  };
}
