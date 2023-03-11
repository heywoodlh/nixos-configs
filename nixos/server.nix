{ config, pkgs, ... }:

{
  imports = [
    ../roles/linux-dotfiles.nix
    ../roles/sshd.nix
    ../roles/sshd-monitor.nix
    ../roles/squid-client.nix
  ];
  
  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;

  # So that `nix search` works
  nix.extraOptions = '' 
    extra-experimental-features = nix-command flakes
  '';

  # Packages to install on entire system  
  environment.systemPackages = with pkgs; [
    autoPatchelfHook
    bind
    busybox
    croc
    file
    gcc
    git
    gnumake
    gnupg 
    jq 
    nix-index
    patchelf
    powershell
    python310 
    python310Packages.pip
    unzip
    vim
    wireguard-tools
  ];

  # Enable Docker 
  virtualisation = {
    docker.enable = true;
  };

  # Define user
  users.users.heywoodlh = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/heywoodlh";
    description = "Spencer Heywood";
    extraGroups = [ "wheel" ];
    shell = pkgs.powershell;
  };

  # Allow heywoodlh to run sudo commands without password
  security.sudo.wheelNeedsPassword = false;
}
