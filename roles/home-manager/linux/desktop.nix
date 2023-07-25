{ config, pkgs, home-manager, ... }:

{
  imports = [
    ../firefox/linux.nix
  ];

  home.packages = with pkgs; [
    _1password-gui
    acpi
    arch-install-scripts
    guake
    gnome.gnome-screenshot
    inotify-tools
    keyutils
    libnotify #(notify-send)
    nixos-install-tools
    nordic
    pinentry-rofi
    rofi
    tailscale
    virt-manager
    xclip
    xdotool
  ];

  home.shellAliases = {
    open = "xdg-open";
    captive-portal = "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
  };

  # Profile
  home.file.".face" = {
    source = builtins.fetchurl {
      url = "https://avatars.githubusercontent.com/u/18178614?v=4";
      sha256 = "sha256:02937kl4qmj29gms9r06kckq8fjpvl40bqi9vpxipwa4xy0wrymg";
    };
  };

  # 1Password GUI settings
  home.file.".config/1Password/settings/settings.json" = {
    text = ''
      {
        "version": 1,
        "ui.routes.lastUsedRoute": "{\"type\":\"ItemDetail\",\"content\":{\"itemListRoute\":{\"unlockedRoute\":{\"collectionUuid\":\"UTCG7LWIBNC7LHEM5OSPMN7J64\"},\"itemListType\":{\"type\":\"Category\",\"content\":\"114\"},\"category\":null,\"sortBehavior\":null},\"itemId\":\"1CB\"}}",
        "security.authenticatedUnlock.enabled": true,
        "sshAgent.storeKeyTitles": true,
        "sshAgent.storeSshKeyTitlesResponseGiven": true,
        "sshAgent.enabled": true,
        "keybinds.open": "",
        "keybinds.quickAccess": "",
        "app.theme": "dark",
        "appearance.interfaceDensity": "compact",
        "developers.cliSharedLockState.enabled": true,
        "app.useHardwareAcceleration": true,
        "authTags": {
          "app.useHardwareAcceleration": "QroNuMzaoNSAt92MMVg6Od7R1nRiyKx+yNsJjrkITy0",
          "developers.cliSharedLockState.enabled": "BENLWIG69/EFYJWyUrsTvfcCGGi6VZpT/pCsbt1fIdE",
          "keybinds.open": "J2ZIPrxfDVulvqV10I0DSxDAeCeKdPrnA8VN5QQhccQ",
          "keybinds.quickAccess": "DrO+203uZNRbp50aXYKsA9HUEKj6lLKwlmS1+uR8YS8",
          "security.authenticatedUnlock.enabled": "af75cCzvjtC4tmat7GMO3X8gw7EGbMzF1A9iNVTzlNg",
          "sshAgent.enabled": "BnZKtIeW3NcF4eo/9EvXSP4drNb8HYijf5PL2tK4SXA",
          "sshAgent.storeKeyTitles": "fuN25iiDAt1/G7H2KFgu+3Yi+38WWWrz1ZEtiysgyVk",
          "sshAgent.storeSshKeyTitlesResponseGiven": "Q4RomTjUe69OBCBWnyZD0St1F3psDo/+u/GX9hfoF8I",
          "ui.routes.lastUsedRoute": "8XGr1Jjakozu4u73yri5yQEvNvtQhc0hxnqn3fZP2O4"
          }
      }'';
    };
}
