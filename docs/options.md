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



## heywoodlh\.gnome\.enable



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



## heywoodlh\.home\.gnome\.enable



Enable heywoodlh gnome configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/gnome\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/home/modules/gnome.nix)



## heywoodlh\.home\.hyprland\.enable



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



## heywoodlh\.hyprland\.enable



Enable heywoodlh hyprland configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/hyprland\.nix](https://github.com/heywoodlh/nixos-configs/tree/master/nixos/modules/hyprland.nix)


