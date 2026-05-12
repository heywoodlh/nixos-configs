## heywoodlh\.apple-silicon\.enable



Enable heywoodlh apple-silicon configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.cachefile

Asahi Linux cache file name in ` /boot `\.



*Type:*
unspecified value



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.firmwarefile



Asahi Linux all firmware file name in ` /boot `\.



*Type:*
unspecified value



*Default:*

```nix
"all_firmware.tar.gz"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.hash



Hashes for firmware files\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.hash\.cache



Hash for kernel cache\.
Retrieve with ` nix hash convert --hash-algo sha256 $(nix-prefetch-url /boot/asahi/<cachefile>) `\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi.nix)



## heywoodlh\.apple-silicon\.hash\.firmware



Hash for firmware file\.
Retrieve with ` nix hash convert --hash-algo sha256 $(nix-prefetch-url /boot/asahi/all_firmware.tar.gz) `\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/asahi.nix)



## heywoodlh\.backup\.enable



Enable heywoodlh backup client configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups.nix)



## heywoodlh\.backup\.publicKeys



List of public keys to use for backups\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*

```nix
[
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJszbIpuxux7oAANlLC+RphqlEW4Ak1128QMvkI06TiY root@homelab"
]
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups.nix)



## heywoodlh\.backup\.server



Enable heywoodlh backup server (duplicati) configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups.nix)



## heywoodlh\.backup\.username



Username for backups over SSH\.



*Type:*
string



*Default:*

```nix
"backups"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/backups.nix)



## heywoodlh\.cloudflared



Enable heywoodlh cloudflared configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cloudflared\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cloudflared.nix)



## heywoodlh\.console



Enable heywoodlh console configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/console\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/console.nix)



## heywoodlh\.cosmic



Enable heywoodlh cosmic desktop configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cosmic\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cosmic.nix)



## heywoodlh\.darwin\.choose-launcher\.enable



Enable heywoodlh choose-launcher configuration (offline-only Spotlight replacement)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/choose-launcher\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/choose-launcher.nix)



## heywoodlh\.darwin\.choose-launcher\.skhd



Integrate choose-launcher with SKHD\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/choose-launcher\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/choose-launcher.nix)



## heywoodlh\.darwin\.choose-launcher\.user



Which user to enable choose-launcher for\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/choose-launcher\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/choose-launcher.nix)



## heywoodlh\.darwin\.raycast\.enable



Enable heywoodlh Raycast configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/raycast\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/raycast.nix)



## heywoodlh\.darwin\.raycast\.user



Which user to change Cmd+Space shortcut for Spotlight to Ctrl+Shift+Space\.
If unset, does not change shortcut\.
Reboot required for Spotlight shortcut to apply\. Sometimes doesn’t work, change manually if needed\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/raycast\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/raycast.nix)



## heywoodlh\.darwin\.sketchybar\.enable



Enable heywoodlh nord-themed sketchybar\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/sketchybar\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/sketchybar.nix)



## heywoodlh\.darwin\.stage-manager\.enable



Enable heywoodlh Stage Manager config\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/stage-manager\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/stage-manager.nix)



## heywoodlh\.darwin\.yabai\.enable



Enable heywoodlh Yabai and SKHD for keyboard shortcuts and window tiling\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/yabai\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/yabai.nix)



## heywoodlh\.darwin\.yabai\.extraSkhdConfig



Extra SKHD conf to append to heywoodlh\.darwin\.yabai\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/yabai\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/yabai.nix)



## heywoodlh\.darwin\.yabai\.extraYabaiConfig



Extra Yabai conf to append to heywoodlh\.darwin\.yabai\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/yabai\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/darwin/modules/yabai.nix)



## heywoodlh\.defaults\.enable



Enable heywoodlh defaults\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.audio



Enable heywoodlh audio configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.bluetooth



Enable heywoodlh bluetooth configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.hostname



Hostname for system\.



*Type:*
string



*Default:*

```nix
"nixos"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.keyring



Enable heywoodlh keyring configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.networkmanager



Enable heywoodlh network manager\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.quietBoot



Suppress boot output\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.syncthing



Enable heywoodlh syncthing configuration\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.tailscale



Enable heywoodlh tailscale configuration\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.timezone



Set system timezone\.



*Type:*
string



*Default:*

```nix
"America/Denver"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user



User for heywoodlh configuration\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.description



Full name of user for heywoodlh defaults\.



*Type:*
string



*Default:*

```nix
"Spencer Heywood"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.homeDir



Home directory for user for heywoodlh defaults\.



*Type:*
absolute path



*Default:*

```nix
"/home/heywoodlh"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.icon



Icon for user\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.name



Username for heywoodlh defaults\.



*Type:*
string



*Default:*

```nix
"heywoodlh"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.defaults\.user\.uid



UID for user for heywoodlh defaults\.



*Type:*
signed integer



*Default:*

```nix
1000
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/defaults.nix)



## heywoodlh\.gnome



Enable heywoodlh gnome configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/gnome\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/gnome.nix)



## heywoodlh\.helix



Enable heywoodlh Helix configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/helix\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/helix.nix)



## heywoodlh\.home\.aerc\.enable



Enable heywoodlh aerc configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/aerc\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/aerc.nix)



## heywoodlh\.home\.aerc\.accounts



Enable heywoodlh aerc accounts\. Only useful to the author\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/aerc\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/aerc.nix)



## heywoodlh\.home\.applications



List of custom applications to create\.



*Type:*
list of attribute set of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/applications\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/applications.nix)



## heywoodlh\.home\.autostart



List of custom applications to autostart\.



*Type:*
list of attribute set of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/linux-autostart\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/linux-autostart.nix)



## heywoodlh\.home\.bluetuith



Enable heywoodlh Vim-keybindings bluetuith configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/bluetuith\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/bluetuith.nix)



## heywoodlh\.home\.btop



Enable heywoodlh btop nord configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/btop\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/btop.nix)



## heywoodlh\.home\.cava



Enable heywoodlh cava configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/cava\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/cava.nix)



## heywoodlh\.home\.cosmic



Enable heywoodlh cosmic configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/cosmic\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/cosmic.nix)



## heywoodlh\.home\.darwin\.defaults\.enable



Configure MacOS defaults\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.defaults\.privacy



Configure MacOS defaults for better privacy\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.defaults\.security



Configure MacOS defaults for better security\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.defaults\.ux



Configure MacOS defaults for a better UX\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-defaults.nix)



## heywoodlh\.home\.darwin\.disable-spotlight



Change Spotlight keyboard shortcut to Ctrl + Shift + Space\.
Reboot is required to apply this change\. Sometimes doesn’t work, change manually if needed\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/disable-spotlight\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/disable-spotlight.nix)



## heywoodlh\.home\.darwin\.nord-terminal



Enable heywoodlh Terminal\.app Nord configuration\.
Warning: will overwrite existing settings\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/nord-terminal\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/nord-terminal.nix)



## heywoodlh\.home\.darwin\.protondrive



Symlink ProtonDrive accounts to $HOME/mnt/protondrive-\*



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-protondrive-link\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/darwin-protondrive-link.nix)



## heywoodlh\.home\.defaults



Enable heywoodlh home-manager defaults\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/base\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/base.nix)



## heywoodlh\.home\.docker-credential-1password\.enable



Install 1password credential helper and configure docker client to use it\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/1password-docker-helper\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/1password-docker-helper.nix)



## heywoodlh\.home\.dockerBins\.enable



Add heywoodlh docker executables to home\.packages\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/docker\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/docker.nix)



## heywoodlh\.home\.ghostty\.enable



Enable heywoodlh vicinae configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty.nix)



## heywoodlh\.home\.ghostty\.command



Ghostty default command\.



*Type:*
string



*Default:*

```nix
"/nix/store/749wilc3pas0i8cmq3ljz5l7i4vk6cmy-tmux/bin/tmux"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty.nix)



## heywoodlh\.home\.ghostty\.extraSettings



Extra settings to append to ghostty home-manager configuration\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty.nix)



## heywoodlh\.home\.ghostty\.fontSize



Ghostty font size\.



*Type:*
signed integer



*Default:*

```nix
16
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty.nix)



## heywoodlh\.home\.ghostty\.quickTerminalKeybind



Keybinding for Quick Terminal\.



*Type:*
string



*Default:*

```nix
"global:ctrl+grave_accent=toggle_quick_terminal"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/ghostty.nix)



## heywoodlh\.home\.github-cli



Enable heywoodlh home-manager GitHub CLI configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/gh\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/gh.nix)



## heywoodlh\.home\.gnome



Enable heywoodlh gnome configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/gnome\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/gnome.nix)



## heywoodlh\.home\.guake



Enable heywoodlh guake configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/guake\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/guake.nix)



## heywoodlh\.home\.helix\.enable



Enable heywoodlh helix configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix.nix)



## heywoodlh\.home\.helix\.ai



Enable machine learning tooling with lsp-ai (local Ollama and GitHub Copilot)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix.nix)



## heywoodlh\.home\.helix\.homelab



Enable heywoodlh homelab-dependent configuration\.
Will only be useful to author\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix.nix)



## heywoodlh\.home\.helix\.local



Prefer local vs cloud ai\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix.nix)



## heywoodlh\.home\.helix\.model



Default Ollama model to use for llama chat\.



*Type:*
string



*Default:*

```nix
"llama3:8b"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/helix.nix)



## heywoodlh\.home\.hyprland



Enable heywoodlh hyprland configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/hyprland\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/hyprland.nix)



## heywoodlh\.home\.librewolf\.enable



Enable heywoodlh LibreWolf configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.librewolf\.default



Make default browser\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.librewolf\.search



Search engine to use in non-private windows – DDG is default for private\.



*Type:*
string



*Default:*

```nix
"duckduckgo"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.librewolf\.socks



User for heywoodlh configuration\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.librewolf\.socks\.noproxy



SOCKS proxy no proxy string\.



*Type:*
null or string



*Default:*

```nix
"localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10,.ts.net,.svc.cluster.local"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.librewolf\.socks\.port



SOCKS proxy port\.



*Type:*
signed integer



*Default:*

```nix
1080
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.librewolf\.socks\.proxy



SOCKS proxy address\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/librewolf.nix)



## heywoodlh\.home\.lima\.enable



Run a Lima Docker VM as a service\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/lima\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/lima.nix)



## heywoodlh\.home\.lima\.context



Configure Lima VM Docker context\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/lima\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/lima.nix)



## heywoodlh\.home\.llm\.enable



Enable heywoodlh llm configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/llm\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/llm.nix)



## heywoodlh\.home\.llm\.homelab



This option is only useful to author\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/llm\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/llm.nix)



## heywoodlh\.home\.marp\.enable



Enable heywoodlh marp configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/marp\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/marp.nix)



## heywoodlh\.home\.moonlight



Use more recent build of Moonlight\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/moonlight\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/moonlight.nix)



## heywoodlh\.home\.onepassword\.enable



Enable heywoodlh 1password GUI configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.package



1Password GUI package to use\.



*Type:*
package



*Default:*

```nix
<derivation 1password-8.12.8>
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.extraArgs



Extra arguments to pass 1Password GUI executable\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.gpu



Enable GPU acceleration for 1Password GUI\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword.nix)



## heywoodlh\.home\.onepassword\.wrapper



1Password GUI wrapper to reference throughout heywoodlh configurations\.



*Type:*
package



*Default:*

```nix
<derivation 1password-gui-wrapper>
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/onepassword.nix)



## heywoodlh\.home\.vicinae\.enable



Enable heywoodlh vicinae configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/vicinae\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/home/modules/vicinae.nix)



## heywoodlh\.hyprland



Enable heywoodlh hyprland configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/hyprland\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/hyprland.nix)



## heywoodlh\.intel-mac



Enable configuration for Intel-based Macs\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/intel-mac\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/intel-mac.nix)



## heywoodlh\.laptop



Enable heywoodlh laptop configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/laptop\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/laptop.nix)



## heywoodlh\.luks\.enable



Enable Yubikey luks single factor decryption\.
See the following gist for setup example:
https://gist\.github\.com/heywoodlh/4cc0254359b173ba9f9a1ea8f3b2e49f



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks.nix)



## heywoodlh\.luks\.boot



Full path of FAT boot device (i\.e\. /dev/nvme0n1p1)\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks.nix)



## heywoodlh\.luks\.fido



Use FIDO device decryption\.
Setup with: ` sudo systemd-cryptenroll /dev/nvme0n1p2 --fido2-device=auto --fido2-with-user-presence=yes --fido2-with-client-pin=no `



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks.nix)



## heywoodlh\.luks\.name



LUKS device name\.



*Type:*
string



*Default:*

```nix
"luks"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks.nix)



## heywoodlh\.luks\.uuid



LUKS block device UUID\.
Obtain with ` sudo blkid `\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks.nix)



## heywoodlh\.luks\.yubikey

Enable Yubikey luks single factor decryption\.
See the following gist for setup example:
https://gist\.github\.com/heywoodlh/4cc0254359b173ba9f9a1ea8f3b2e49f



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/luks.nix)



## heywoodlh\.nixos\.cachyos-kernel\.enable



Enable heywoodlh cachyos-kernel configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cachyos-kernel\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cachyos-kernel.nix)



## heywoodlh\.nixos\.cachyos-kernel\.kernel



Desired CachyOS kernel version\.



*Type:*
string



*Default:*

```nix
"linuxPackages-cachyos-latest-zen4"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cachyos-kernel\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/cachyos-kernel.nix)



## heywoodlh\.nixos\.gaming



Enable heywoodlh gaming configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/gaming\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/gaming.nix)



## heywoodlh\.nixos\.nvidia-patch



Enable heywoodlh nvidia-patch configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/nvidia-patch\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/nvidia-patch.nix)



## heywoodlh\.nixos\.scrutiny\.enable



Enable heywoodlh scrutiny monitoring configuration\.
Remember to run ` sudo systemctl start scrutiny-collector.timer ` for initial dashboard population\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/scrutiny\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/scrutiny.nix)



## heywoodlh\.nixos\.scrutiny\.ntfy



URL for NTFY notifications\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/scrutiny\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/scrutiny.nix)



## heywoodlh\.nixos\.scrutiny\.port



Port for scrutiny web service\.



*Type:*
signed integer



*Default:*

```nix
3050
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/scrutiny\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/scrutiny.nix)



## heywoodlh\.nixos\.steam-deck



Enable heywoodlh Steam Deck configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/steam-deck\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/steam-deck.nix)



## heywoodlh\.nixos\.sunshine\.enable



Enable heywoodlh sunshine configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sunshine\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sunshine.nix)



## heywoodlh\.nixos\.sunshine\.user



User for heywoodlh configuration\.



*Type:*
string



*Default:*

```nix
"heywoodlh"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sunshine\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sunshine.nix)



## heywoodlh\.nixos\.vmware-workstation



Enable heywoodlh VMWare host configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/vmware-workstation\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/vmware-workstation.nix)



## heywoodlh\.rayhunter\.enable



Enable heywoodlh rayhunter ntfy reverse proxy configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter.nix)



## heywoodlh\.rayhunter\.interface



RayHunter USB interface name\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter.nix)



## heywoodlh\.rayhunter\.ntfy



NTFY URL to proxy\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter.nix)



## heywoodlh\.rayhunter\.port



Reverse proxy port\.



*Type:*
signed integer



*Default:*

```nix
6767
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter.nix)



## heywoodlh\.rayhunter\.user



User to run the reverse proxy\.



*Type:*
string



*Default:*

```nix
"rayhunter"
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/rayhunter.nix)



## heywoodlh\.server



Enable heywoodlh server configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/server\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/server.nix)



## heywoodlh\.sshd\.enable



Enable heywoodlh ssh configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sshd\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sshd.nix)



## heywoodlh\.sshd\.mfa



Enable mfa configuration for SSH\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sshd\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/sshd.nix)



## heywoodlh\.stylix\.enable



Enable heywoodlh Stylix configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [/nix/store/51rg541wxn4bpfwyqawqb7k0plmncbwb-source/base/stylix\.nix](/nix/store/51rg541wxn4bpfwyqawqb7k0plmncbwb-source/base/stylix.nix)



## heywoodlh\.stylix\.theme



Stylix theme\.



*Type:*
string



*Default:*

```nix
"catppuccin-macchiato"
```

*Declared by:*
 - [/nix/store/51rg541wxn4bpfwyqawqb7k0plmncbwb-source/base/stylix\.nix](/nix/store/51rg541wxn4bpfwyqawqb7k0plmncbwb-source/base/stylix.nix)



## heywoodlh\.stylix\.username



Username to apply home-manager configs to\.



*Type:*
string



*Default:*

```nix
"heywoodlh"
```

*Declared by:*
 - [/nix/store/51rg541wxn4bpfwyqawqb7k0plmncbwb-source/base/stylix\.nix](/nix/store/51rg541wxn4bpfwyqawqb7k0plmncbwb-source/base/stylix.nix)



## heywoodlh\.vm



Enable heywoodlh virtual machine configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/vm\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/vm.nix)



## heywoodlh\.workstation



Enable heywoodlh workstation configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/workstation\.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/main/nixos/modules/workstation.nix)


