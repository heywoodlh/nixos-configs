{ config, modulesPath, pkgs, lib, ... }:
{
    imports = [
        (fetchTarball {
            url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
            sha256 = "1qga1cmpavyw90xap5kfz8i6yz85b0blkkwvl00sbaxqcgib2rvv";
        })
    ];

    services.vscode-server.enable = true;
    # still requires systemctl --user enable auto-fix-vscode-server.service
    # systemctl --user start auto-fix-vscode-server.service
    environment.systemPackages = with pkgs; [
        htop
        lsd
        fd
        bat
        fzf
        zoxide
        jq
        yq
        fish
        starship
    ];

    programs.fish.enable = true;

    users.users.josh = {
        shell = "/run/current-system/sw/bin/fish";
        isNormalUser = true;
        group = "users";
        home = "/home/josh.linux";
    }; # Settings need to be specified here too so folders aren't overwritten/wiped
}