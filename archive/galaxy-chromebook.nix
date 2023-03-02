{ config, pkgs, lib, ... }:

{

  # https://github.com/olm3ca/Galaxy-Chromebook#part-3-linux-manjaro-fedora
  boot = {
    kernelParams = [ "mem_sleep_default=deep" ];
    blacklistedKernelModules = [ "atmel_mxt_ts" "cros_ec_typec" ];
  };

  # GNOME settings for Chromebook
  home-manager.users.heywoodlh = {
    home.stateVersion = "22.11";
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom100/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom101/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom100" = {
        name = "rofi-rbw chromebook";
        command = "rofi-rbw --action copy";
        binding = "<Ctrl><Alt>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom101" = {
        name = "rofi launcher chromebook";
        command = "rofi -theme nord -show run -display-run 'run: '";
        binding = "<Alt>space";
      };
    };
  };
}
