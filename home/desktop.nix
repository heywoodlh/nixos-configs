{ config, pkgs, lib, home-manager, nur, myFlakes, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  homeDir = config.home.homeDirectory;
  vscodeSettingsDir = if pkgs.stdenv.isDarwin then
    "Library/Application Support/Code/User"
  else
    ".config/Code/User";
  code-reset = pkgs.writeShellScriptBin "code-reset" ''
    rm -rf ~/.vscode ~/Documents/Code ${vscodeSettingsDir}
  '';
  arc-settings = ./share/arc-browser.plist;
in {
  home.packages = [
    code-reset
    pkgs.mdp
  ];

  # post-install jobs for MacOS or Linux
  home.activation = if pkgs.stdenv.isDarwin then {
    # configure arc on macos
    arcConfiguration = ''
      /usr/bin/plutil -convert binary1 ${arc-settings} -o ~/Library/Preferences/company.thebrowser.Browser.plist
    '';
  } else {};

  # Add my custom docker executables
  heywoodlh.home.dockerBins.enable = true;

  # Enable Marp
  heywoodlh.home.marp.enable = true;

  # Enable ghostty
  heywoodlh.home.ghostty.enable = true;

  # Enable librewolf
  heywoodlh.home.librewolf = {
    enable = true;
    search = "kagi";
    socks = {
      proxy = "10.64.0.1";
      port = 1080;
    };
  };

  # Enable syncthing
  services.syncthing.enable = true;

  # Logbash wrapper
  home.file.".config/fish/config.fish" = {
    enable = true;
    text = ''
      function logbash
        kubectl exec -it -n monitoring $(kubectl get pods -n monitoring | grep -i logbash | head -1 | awk '{print $1}') -- logbash $argv
      end
    '';
  };
}
