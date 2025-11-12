{
  description = "heywoodlh 1password helper scripts";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      op-unlock = pkgs.writeShellScriptBin "op-unlock" ''
        env | grep -iq OP_SESSION || eval $(${pkgs._1password-cli}/bin/op signin) && export OP_SESSION
        echo "export OP_SESSION=$OP_SESSION"
      '';
      op-wrapper = pkgs.writeShellScriptBin "op-wrapper.sh" ''
        ${op-unlock}/bin/op-unlock | grep -v export
        ${pkgs._1password-cli}/bin/op "$@"
      '';
      op-desktop-settings = pkgs.writeText "settings.json" ''
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
        }
      '';
    in {
      packages = rec {
        op = pkgs.writeShellScriptBin "op" ''
          ${op-wrapper}/bin/op-wrapper.sh "$@"
        '';
        op-desktop-setup = pkgs.writeShellScriptBin "op-setup" ''
          mkdir -p ~/.config/1Password/settings
          cp ${op-desktop-settings} ~/.config/1Password/settings/settings.json
        '';
        default = op;
        };
      }
    );
}
