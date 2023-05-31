{ config, pkgs, ... }:

{
  "org/gnome/desktop/input-sources" = {
    xkb-options = ["caps:super"];
  };
  "apps/guake/general" = {
    abbreviate-tab-names = false;
    compat-delete = "delete-sequence";
    default-shell = "/home/heywoodlh/.nix-profile/bin/tmux";
    display-n = 0;
    display-tab-names = 0;
    gtk-prefer-dark-theme = true;
    gtk-theme-name = "Adwaita-dark";
    gtk-use-system-default-theme = true;
    hide-tabs-if-one-tab = false;
    history-size = 1000;
    load-guake-yml = true;
    max-tab-name-length = 100;
    mouse-display = true;
    open-tab-cwd = true;
    prompt-on-quit = true;
    quick-open-command-line = "gedit %(file_path)s";
    restore-tabs-notify = false;
    restore-tabs-startup = false;
    save-tabs-when-changed = false;
    schema-version = "3.9.0";
    scroll-keystroke = true;
    start-at-login = true;
    use-default-font = false;
    use-login-shell = false;
    use-popup = false;
    use-scrollbar = true;
    use-trayicon = false;
    window-halignment = 0;
    window-height = 50;
    window-losefocus = false;
    window-refocus = false;
    window-tabbar = false;
    window-width = 100;
  };
  "apps/guake/keybindings/global" = {
    show-hide = "<Primary>grave";
  };
  "apps/guake/keybindings/local" = {
    focus-terminal-left = "<Primary>braceleft";
    focus-terminal-right = "<Primary>braceright";
    split-tab-horizontal = "<Primary>underscore";
    split-tab-vertical = "<Primary>bar";
  };
  "apps/guake/style" = {
    cursor-shape = 1;
  };
  "apps/guake/style/background" = {
    transparency = 82;
  };
  "apps/guake/style/font" = {
    allow-bold = true;
    palette = "#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040";
    palette-name = "Nord";
    style = "IosevkaTerm Nerd Font Mono Regular 14";
  };
  "org/gnome/shell" = {
    disable-user-extensions = false;
    disabled-extensions = ["disabled"];
    enabled-extensions = [
      "native-window-placement@gnome-shell-extensions.gcampax.github.com"
      "pop-shell@system76.com"
      "caffeine@patapon.info"
      "hidetopbar@mathieu.bidon.ca"
      "gsconnect@andyholmes.github.io"
    ];
    favorite-apps = ["firefox.desktop" "alacritty.desktop"];
    had-bluetooth-devices-setup = true;
    remember-mount-password = false;
    welcome-dialog-last-shown-version = "42.4";
  };
  "org/gnome/mutter" = {
    dynamic-workspaces = false;
  };
  "org/gnome/shell/extensions/hidetopbar" = {
    enable-active-window = false;
    enable-intellihide = false;
  };
  "org/gnome/desktop/interface" = {
    clock-show-seconds = true;
    clock-show-weekday = true;
    color-scheme = "prefer-dark";
    enable-hot-corners = false;
    font-antialiasing = "grayscale";
    font-hinting = "slight";
    gtk-theme = "Nordic";
    toolkit-accessibility = true;
  };
  "org/gnome/desktop/wm/keybindings" = {
    activate-window-menu = ["disabled"];
    toggle-message-tray = ["disabled"];
    close = "['<Super>q', '<Alt>F4']";
    maximize = ["disabled"];
    minimize = "['<Super>comma']";
    move-to-monitor-down = ["disabled"];
    move-to-monitor-left = ["disabled"];
    move-to-monitor-right = ["disabled"];
    move-to-monitor-up = ["disabled"];
    move-to-workspace-down = ["disabled"];
    move-to-workspace-up = ["disabled"];
    switch-to-workspace-left = ["<Super>bracketleft"];
    switch-to-workspace-right = ["<Super>bracketright"];
    switch-input-source = ["disabled"];
    switch-input-source-backward = ["disabled"];
    toggle-maximized = ["<Super>Up"];
    unmaximize = ["disabled"];
  };
  "org/gnome/desktop/wm/preferences" = {
    button-layout = "close,minimize,maximize:appmenu";
    num-workspaces = 10;
  };
  "org/gnome/shell/extensions/pop-shell" = {
    focus-right = ["disabled"];
    tile-by-default = true;
    tile-enter = ["disabled"];
  };
  "org/gnome/desktop/notifications" = {
    show-in-lock-screen = false;
  };
  "org/gnome/desktop/peripherals/touchpad" = {
    tap-to-click = true;
    two-finger-scrolling-enabled = true;
  };
  "org/gnome/settings-daemon/plugins/media-keys" = {
    next = [ "<Shift><Control>n" ];
    previous = [ "<Shift><Control>p" ];
    play = [ "<Shift><Control>space" ];
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
    ];
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
    name = "terminal super";
    command = "alacritty";
    binding = "<Super>Return";
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
    name = "terminal ctrl_alt";
    command = "alacritty";
    binding = "<Ctrl><Alt>t";
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
    name = "rofi-rbw";
    command = "rofi-rbw --action copy";
    binding = "<Ctrl><Super>s";
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
    name = "rofi launcher";
    command = "rofi -theme nord -show run -display-run 'run: '";
    binding = "<Super>space";
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
    binding = "<Ctrl><Shift>s";
    command = "scrot /home/heywoodlh/Documents/screenshots/scrot-+%Y-%m-%d_%H_%M_%S.png -s -e 'xclip -selection clipboard -t image/png -i $f'";
    name = "screenshot";
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
    binding = "<Shift><Control>e";
    command = "/home/heywoodlh/bin/vim-ime.py --cmd 'gnome-terminal --geometry=60x8 -- vim' --outfile '/home/heywoodlh/tmp/vim-ime.txt'";
    name = "vim-ime";
  };
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
    binding = "<Shift><Control>b";
    command = "bash -c 'notify-send $(acpi -b | grep -Eo [0-9]+%)'";
    name = "battpop";
  };
}
