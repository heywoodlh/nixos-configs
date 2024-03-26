## Making changes to iTerm Home-Manager managed configuration

1. Remove config:

```
cd ~/.config/iterm2
cp com.googlecode.iterm2.plist{,.bak}
cp iterm2-profiles.json{,.bak}
rm com.googlecode.iterm2.plist iterm2-profiles.json
cp com.googlecode.iterm2.plist{.bak,}
cp iterm2-profiles.json{.bak,}
chmod +w *.plist *.json
```

2. Make changes in iTerm Settings

3. Save all profiles as JSON to `~/.config/iterm2/iterm2-profiles.json`

4. Quit iTerm

5. Add contents of `~/.config/iterm2/com.googlecode.iterm2.plist` and
   `~/.config/iterm2/iterm2-profiles.json` to `com.googlecode.iterm2.plist.nix`
   and `iterm2-profiles.json.nix` in `home/iterm2`

6. Replace `tmux` executables in nix files with `${myTmux}/bin/tmux`

7. Remove writable config files:

```
rm ~/.config/iterm2/*plist* ~/.config/iterm2/*json*
rm -rf ~/Library/Application\ Support/iTerm2/*
```

8. Rebuild Nix-Darwin config
