{
  lib,
  pkgs,
  cart,
  ...
}: {
  imports = [
    ../roles/mac-mini.nix
    ../roles/workstation.nix
  ];

  heywoodlh.nix-llama.enable = false;
  heywoodlh.sshd.enable = true;

  networking.applicationFirewall = {
    enable = lib.mkForce false;
    blockAllIncoming = lib.mkForce false;
    enableStealthMode = lib.mkForce false;
  };

  cart = {
    enable = true;
    user = "heywoodlh";
    package = cart.packages.${pkgs.stdenv.hostPlatform.system}.cart;
    applications = [
      {
        url = "https://github.com/utmapp/UTM/releases/download/v4.6.4/UTM.dmg";
        hash = "aad86726152b15a3e963cf778a0b0dfd8e818736b381aed2699d974a18845427";
      }
      {
        url = "https://github.com/ibrahimcetin/reins/releases/download/v1.3.0/Reins-macOS.dmg";
        hash = "8db9f87297f2b474f81cc07326304a4e4144465b31cfb0713aef4900cbdecb5a";
      }
    ];
  };

  home-manager.users.heywoodlh = {
    imports = [../../home/roles/kiwix.nix];
    heywoodlh.home = {
      lima.nixos.memory = 12;
      t3 = {
        enable = true;
        address = "100.125.243.118";
      };
    };
  };
}
