{ config, pkgs, ... }:

{
  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
     vim git gnupg firefox terminator guake python39 nodejs yarn rofi jq bitwarden-cli keyutils pass pass-otp xclip syncthing bitwarden gnome3.gnome-tweak-tool gnome3.dconf-editor wireguard-tools busybox unzip go mosh bind gcc gnumake chrome-gnome-shell ansible python39Packages.setuptools file patchelf nix-index autoPatchelfHook _1password-gui python39Packages.pip maim sxhkd desktop-file-utils libnotify neofetch gnomeExtensions.dash-to-dock qemu-utils keynav xdotool home-manager peru pinentry-curses coreutils nodePackages.typescript
  ];

  
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Display server applications
  services.xserver = {
    enable = true;
    layout = "us";
    libinput = {
      enable = true;
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome3 = {
      enable = true;
      extraGSettingsOverridePackages = with pkgs; [ gnome3.gnome-settings-daemon ];
      extraGSettingsOverrides = ''
      [org.gnome.settings-daemon.plugins.media-keys]
      custom-keybindings=[
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/'
	'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/'
	'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/'
	'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/'
      ]


      [org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0]
      binding='<Ctrl><Alt>t'
      command='terminator'
      name='Open terminal'

      [org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom3]
      binding='<Super><Space>'
      command='rofi -theme nord -show run -display-run "run: "'
      name='App Launcher'
    '';
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    anbox = {
      enable = true;
    };
  };
  
  services = {
    unclutter = {
      enable = true;
      timeout = 10;
    };
  };

  programs.adb.enable = true;  

  programs.firejail = {
    enable = true;
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy2";
  };

  users.users.heywoodlh = {
      isNormalUser = true;
      uid = 1000;
      home = "/home/heywoodlh";
      description = "Spencer Heywood";
      extraGroups = [ "wheel" "networkmanager" "adbusers" ];
      shell = pkgs.bash;
  };

  nix.allowedUsers = [ "heywoodlh" ];

  services = {
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
  };

  networking.firewall.enable = true;
}
