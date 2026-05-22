{ pkgs, lib, helium, ... }:

with lib;

let
  vscodeSettingsDir = if pkgs.stdenv.isDarwin then
    "Library/Application Support/Code/User"
  else
    ".config/Code/User";
  code-reset = pkgs.writeShellScriptBin "code-reset" ''
    rm -rf ~/.vscode ~/Documents/Code ${vscodeSettingsDir}
  '';
  system = pkgs.stdenv.hostPlatform.system;
in {
  home.packages = [
    code-reset
    pkgs.mdp
  ] ++ optionals (pkgs.stdenv.isLinux) [
    helium.packages.${system}.helium
  ];

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

  heywoodlh.home = {
    dockerBins.enable = true;
    marp.enable = true;
    ghostty.enable = true;
    cava = pkgs.stdenv.isLinux;
    librewolf = {
      enable = true;
      search = "kagi";
      socks = {
        proxy = "10.64.0.1";
        port = 1080;
      };
    };
  };
}
