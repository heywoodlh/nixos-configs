{
  pkgs,
  cart,
  ...
}: {
  imports = [../roles/workstation.nix];

  heywoodlh.nix-llama = {
    enable = false;
    contextSize = 65536;
    extraConf.tuning = {
      kvCacheType = "q8_0";
      promptCacheMiB = 2048;
      loadMode = "mmap";
      parallel = 1;
    };
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
        url = "https://github.com/podman-desktop/podman-desktop/releases/download/v1.17.2/podman-desktop-1.17.2-universal.dmg";
        hash = "d73c81a859f5792329818893736b28f8dd8a5243cca41c8573ed7c2095f69182";
      }
    ];
  };

  homebrew.casks = ["steam"];

  home-manager.users.heywoodlh = {
    imports = [../../home/roles/kiwix.nix];
    heywoodlh.home.lima.nixos.memory = 12;
  };
}
