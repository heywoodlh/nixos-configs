## boot\.m1n1CustomLogo

Custom logo to build into m1n1\. The path must point to a 256x256 PNG\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/boot-m1n1](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/boot-m1n1)



## boot\.m1n1ExtraOptions



Append extra options to the m1n1 boot binary\. Might be useful for fixing
display problems on Mac minis\.
https://github\.com/AsahiLinux/m1n1/issues/159



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/boot-m1n1](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/boot-m1n1)



## hardware\.asahi\.enable



Enable the basic Asahi Linux components, such as kernel and boot setup\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default\.nix](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default.nix)



## hardware\.asahi\.extractPeripheralFirmware



Automatically extract the non-free non-redistributable peripheral
firmware necessary for features like Wi-Fi\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/peripheral-firmware](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/peripheral-firmware)



## hardware\.asahi\.overlay



The nixpkgs overlay for asahi packages\.



*Type:*
nixpkgs overlay



*Default:*
` "overlay provided with the module" `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default\.nix](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default.nix)



## hardware\.asahi\.peripheralFirmwareDirectory



Path to the directory containing the non-free non-redistributable
peripheral firmware necessary for features like Wi-Fi\. Ordinarily, this
will automatically point to the appropriate location on the ESP\. Flake
users and those interested in maximum purity will want to copy those
files elsewhere and specify this manually\.

Currently, this consists of the files ` all-firmware.tar.gz ` and
` kernelcache* `\. The official Asahi Linux installer places these files
in the ` asahi ` directory of the EFI system partition when creating it\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/peripheral-firmware](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/peripheral-firmware)



## hardware\.asahi\.pkgs



Package set used to build the major Asahi packages\. Defaults to the
ambient set if not cross-built, otherwise re-imports the ambient set
with the system defined by ` hardware.asahi.pkgsSystem `\.



*Type:*
raw value

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default\.nix](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default.nix)



## hardware\.asahi\.pkgsSystem



System architecture that should be used to build the major Asahi
packages, if not the default aarch64-linux\. This allows installing from
a cross-built ISO without rebuilding them during installation\.



*Type:*
string



*Default:*
` "aarch64-linux" `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default\.nix](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/default.nix)



## hardware\.asahi\.setupAsahiSound



Set up the Asahi DSP components so that the speakers and headphone jack
work properly and safely\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/sound](/nix/store/46mpq9a8ma725f8mdi6iw2p7phdyqxcy-source/apple-silicon-support/modules/sound)



## heywoodlh\.apple-silicon



Enable heywoodlh apple-silicon configuration\.



*Type:*
boolean



*Default:*
` false `

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



## home-manager\.enableLegacyProfileManagement



Whether to enable legacy profile management during activation\. When
enabled, the Home Manager activation will produce a per-user
` home-manager ` Nix profile, just like in the standalone installation of
Home Manager\. Typically, this is not desired when Home Manager is
embedded in the system configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.backupCommand



On activation run this command on each existing file
rather than exiting with an error\.



*Type:*
null or string or absolute path



*Default:*
` null `



*Example:*
` ${pkgs.trash-cli}/bin/trash `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.backupFileExtension



On activation move existing files by appending the given
file extension rather than exiting with an error\.



*Type:*
null or string



*Default:*
` null `



*Example:*
` "backup" `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.extraSpecialArgs



Extra ` specialArgs ` passed to Home Manager\. This
option can be used to pass additional arguments to all modules\.



*Type:*
attribute set



*Default:*
` { } `



*Example:*
` { inherit emacs-overlay; } `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.minimal



Whether to enable only the necessary modules that allow home-manager to function\.

This can be used to allow vendoring a minimal list of modules yourself, rather than
importing every single module\.

THIS IS FOR ADVANCED USERS, AND WILL DISABLE ALMOST EVERY MODULE\.
THIS SHOULD NOT BE ENABLED UNLESS YOU KNOW THE IMPLICATIONS\.
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.overwriteBackup



Whether to enable forced overwriting of existing backup files when using ` backupFileExtension `
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.sharedModules



Extra modules added to all users\.



*Type:*
list of raw value



*Default:*
` [ ] `



*Example:*
` [ { home.packages = [ nixpkgs-fmt ]; } ] `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.useGlobalPkgs



Whether to enable using the system configuration’s ` pkgs `
argument in Home Manager\. This disables the Home Manager
options ` nixpkgs.* `\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.useUserPackages



Whether to enable installation of user packages through the
` users.users.<name>.packages ` option\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.users



Per-user Home Manager configuration\.



*Type:*
attribute set of (Home Manager module)



*Default:*
` { } `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)



## home-manager\.verbose



Whether to enable verbose output on activation\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common\.nix](/nix/store/xs7z8954xsf8h8vbdxymkdhm5r9kdp1j-source/nixos/common.nix)


