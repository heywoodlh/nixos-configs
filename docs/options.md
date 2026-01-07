## heywoodlh\.apple-silicon\.enable



Enable heywoodlh apple-silicon configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.cachefile

Asahi Linux cache file name in ` /boot `\.



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.firmwarefile



Asahi Linux all firmware file name in ` /boot `\.



*Type:*
unspecified value



*Default:*
` "all_firmware.tar.gz" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.hash



Hashes for firmware files\.



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.hash\.cache



Hash for kernel cache\.
Retrieve with ` nix hash convert --hash-algo sha256 $(nix-prefetch-url /boot/asahi/<cachefile>) `\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.hash\.firmware



Hash for firmware file\.
Retrieve with ` nix hash convert --hash-algo sha256 $(nix-prefetch-url /boot/asahi/all_firmware.tar.gz) `\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/asahi.nix)



## heywoodlh\.console



Enable heywoodlh console configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/console\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/console.nix)



## heywoodlh\.cosmic



Enable heywoodlh cosmic desktop configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/cosmic\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/cosmic.nix)



## heywoodlh\.darwin\.sketchybar\.enable



Enable heywoodlh nord-themed sketchybar\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/sketchybar\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/sketchybar.nix)



## heywoodlh\.darwin\.stage-manager\.enable



Enable heywoodlh Stage Manager config\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/stage-manager\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/stage-manager.nix)



## heywoodlh\.darwin\.yabai\.enable



Enable heywoodlh Yabai and SKHD for keyboard shortcuts and window tiling\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai.nix)



## heywoodlh\.darwin\.yabai\.extraSkhdConfig



Extra SKHD conf to append to heywoodlh\.darwin\.yabai\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai.nix)



## heywoodlh\.darwin\.yabai\.extraYabaiConfig



Extra Yabai conf to append to heywoodlh\.darwin\.yabai\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai.nix)



## heywoodlh\.darwin\.yabai\.homebrew



Use Yabai and SKHD from Homebrew and not Nixpkgs\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/darwin/modules/yabai.nix)



## heywoodlh\.defaults\.enable



Enable heywoodlh defaults\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.audio



Enable heywoodlh audio configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.bluetooth



Enable heywoodlh bluetooth configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.hostname



Hostname for system\.



*Type:*
string



*Default:*
` "nixos" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.keyring



Enable heywoodlh keyring configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.networkmanager



Enable heywoodlh network manager\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.quietBoot



Suppress boot output\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.syncthing



Enable heywoodlh syncthing configuration\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.tailscale



Enable heywoodlh tailscale configuration\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.timezone



Set system timezone\.



*Type:*
string



*Default:*
` "America/Denver" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user



User for heywoodlh configuration\.



*Type:*
submodule

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.description



Full name of user for heywoodlh defaults\.



*Type:*
string



*Default:*
` "Spencer Heywood" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.homeDir



Home directory for user for heywoodlh defaults\.



*Type:*
absolute path



*Default:*
` "/home/heywoodlh" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.icon



Icon for user\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.name



Username for heywoodlh defaults\.



*Type:*
string



*Default:*
` "heywoodlh" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.uid



UID for user for heywoodlh defaults\.



*Type:*
signed integer



*Default:*
` 1000 `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/defaults.nix)



## heywoodlh\.gnome



Enable heywoodlh gnome configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/gnome\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/gnome.nix)



## heywoodlh\.helix



Enable heywoodlh Helix configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/helix\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/helix.nix)



## heywoodlh\.home\.aerc\.enable



Enable heywoodlh aerc configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/aerc\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/aerc.nix)



## heywoodlh\.home\.aerc\.accounts



Enable heywoodlh aerc accounts\. Only useful to the author\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/aerc\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/aerc.nix)



## heywoodlh\.home\.applications



List of custom applications to create\.



*Type:*
list of attribute set of string



*Default:*
` [ ] `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/applications\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/applications.nix)



## heywoodlh\.home\.autostart



List of custom applications to autostart\.



*Type:*
list of attribute set of string



*Default:*
` [ ] `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/linux-autostart\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/linux-autostart.nix)



## heywoodlh\.home\.cosmic



Enable heywoodlh cosmic configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/cosmic\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/cosmic.nix)



## heywoodlh\.home\.darwin\.defaults\.enable



Configure MacOS defaults\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.defaults\.privacy



Configure MacOS defaults for better privacy\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.defaults\.security



Configure MacOS defaults for better security\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.defaults\.ux



Configure MacOS defaults for a better UX\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.defaults



Enable heywoodlh home-manager defaults\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/base\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/base.nix)



## heywoodlh\.home\.docker-credential-1password\.enable



Install 1password credential helper and configure docker client to use it\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/1password-docker-helper\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/1password-docker-helper.nix)



## heywoodlh\.home\.dockerBins\.enable



Add heywoodlh docker executables to home\.packages\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/docker\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/docker.nix)



## heywoodlh\.home\.gnome



Enable heywoodlh gnome configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/gnome\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/gnome.nix)



## heywoodlh\.home\.guake



Enable heywoodlh guake configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/guake\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/guake.nix)



## heywoodlh\.home\.helix\.enable



Enable heywoodlh helix configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/helix\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/helix.nix)



## heywoodlh\.home\.helix\.ai



Enable machine learning tooling, i\.e\. Copilot, lsp-ai\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/helix\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/helix.nix)



## heywoodlh\.home\.helix\.homelab



Enable heywoodlh homelab-dependent configuration\.
Will only be useful to author\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/helix\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/helix.nix)



## heywoodlh\.home\.hyprland



Enable heywoodlh hyprland configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/hyprland\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/hyprland.nix)



## heywoodlh\.home\.lima\.enable



Run a Lima VM as a service\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/lima\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/lima.nix)



## heywoodlh\.home\.lima\.enableDocker



Enable Lima VM Docker context\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/lima\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/lima.nix)



## heywoodlh\.home\.marp\.enable



Enable heywoodlh marp configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/marp\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/marp.nix)



## heywoodlh\.home\.onepassword\.enable



Enable heywoodlh 1password GUI configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.package



1Password GUI package to use\.



*Type:*
package



*Default:*
` <derivation 1password-8.11.22> `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.extraArgs



Extra arguments to pass 1Password GUI executable\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.gpu



Enable GPU acceleration for 1Password GUI\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.wrapper



1Password GUI wrapper to reference throughout heywoodlh configurations\.



*Type:*
package



*Default:*
` <derivation 1password-gui-wrapper> `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/onepassword.nix)



## heywoodlh\.home\.vicinae\.enable



Enable heywoodlh vicinae configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/vicinae\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/vicinae.nix)



## heywoodlh\.hyprland



Enable heywoodlh hyprland configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/hyprland\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/hyprland.nix)



## heywoodlh\.intel-mac



Enable configuration for Intel-based Macs\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/intel-mac\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/intel-mac.nix)



## heywoodlh\.laptop



Enable heywoodlh laptop configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/laptop\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/laptop.nix)



## heywoodlh\.luksYubikey\.enable



Enable Yubikey luks single factor decryption\.
See the following gist for setup example:
https://gist\.github\.com/heywoodlh/4cc0254359b173ba9f9a1ea8f3b2e49f



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks.nix)



## heywoodlh\.luksYubikey\.device



Full path of FAT boot device (i\.e\. /dev/nvme0n1p1)\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks.nix)



## heywoodlh\.luksYubikey\.name



LUKS device name\.



*Type:*
string



*Default:*
` "luks" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks.nix)



## heywoodlh\.luksYubikey\.uuid



LUKS device UUID\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/luks.nix)



## heywoodlh\.server



Enable heywoodlh server configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/server\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/server.nix)



## heywoodlh\.sshd\.enable



Enable heywoodlh ssh configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/sshd\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/sshd.nix)



## heywoodlh\.sshd\.mfa



Enable mfa configuration for SSH\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/sshd\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/sshd.nix)



## heywoodlh\.vm



Enable heywoodlh virtual machine configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/vm\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/vm.nix)



## heywoodlh\.workstation



Enable heywoodlh workstation configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/workstation\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/workstation.nix)


