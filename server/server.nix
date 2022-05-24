{ config, pkgs, ... }:

let 
  user = "heywoodlh";
  user_uid = 1000;
  user_name = "Spencer Heywood";
  user_ssh_authorized_keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDaODBCtfon69H6DcXavkeEkBuPXaL2Z3x1IMSw9HCvgl5wq/WcrqqEpPmBwD5sFMuc4Fc/POdTd9xu4jbf2vRqBpGNBgTvE5IwrB1uqElRpEmva3jLn5CR0ilJbJeHBruwgQhW8m92goc4NuB/CaQoROnFa0F7QNdy6DMB/uI/YB4ge1fNHPKRWROCN98hxNtsvov0tP+fzhAgQ5esW+1lapYSmQ5W3XQOdk3I3yKCIyd3R4wVgytgduI02nvcLkEsGilpiGprxojwbsRLDF9CUv3b1iGAMSzrDrqcdoVF0+hlSkQZYLtu5F1SQ4cu5y65bgcRXdtRDI9CzZIWHzY94znzAElklBMk3Yk29QhuU6JYQhYpSlDfFzekfolQ1q8UIFWvn1/I1pDS7hJkJ1wcFseUh2ZxiRzyWIXW0nbOJ+7UewroerQb9w3Dcu3MUo75biwEK8oM+qM5/oeLHDojRkVYwTzBhlUZvzRL8S/ngsyinBLk18tvORN6TKw2aik=" ];
in {
  services.openssh.enable = true;
  
  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    vim git gnupg python38 jq starship pass wireguard-tools busybox unzip go mosh bind gcc gnumake ansible file patchelf nix-index autoPatchelfHook python38Packages.pip bash-completion
  ];
 
  virtualisation = {
    docker.enable = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    uid = user_uid;
    home = "/home/${user}";
    description = user_name;
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = user_ssh_authorized_keys;
  };
}
