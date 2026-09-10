{ pkgs, ... }:

{
  home.packages = [
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.dash-to-dock
  ];

  # Yaru (Ubuntu's GTK/icon/cursor/shell theme set), dark variant, config-time
  # only -- home-manager's gtk.* options already generate the matching
  # dconf "org/gnome/desktop/interface" keys themselves (gtk-theme,
  # icon-theme, cursor-theme, color-scheme), confirmed by reading
  # home-manager's own gtk3.nix, so those aren't hand-written below. GNOME's
  # own Appearance light/dark switch keeps working normally on top of this --
  # nothing here fights it, it just isn't driven by it either.
  gtk = {
    enable = true;
    theme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };
    iconTheme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };
    cursorTheme = {
      name = "Yaru"; # one cursor set covers both light and dark
      package = pkgs.yaru-theme;
      size = 24;
    };
    colorScheme = "dark";
  };

  dconf.settings = {
    "org/gnome/shell" = {
      # Caffeine: toggleable "prevent idle/suspend" -- click the mug icon in
      # the top bar, or right-click it for a timed duration.
      #
      # user-theme: lets GNOME Shell's own chrome (top bar, overview) pick
      # up Yaru-dark's bundled shell theme -- vanilla GNOME Shell otherwise
      # ignores shell themes entirely without this extension.
      #
      # dash-to-dock: Ubuntu-style dock instead of GNOME's built-in
      # (non-auto-hiding) dash. Configured below to sit on the bottom edge
      # and auto-hide so it doesn't eat screen real estate.
      enabled-extensions = [
        "caffeine@patapon.info"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Yaru-dark";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      autohide = true;
      dock-fixed = false;
      intellihide = true;
      # dash-to-dock's own Super+1..9 (and Shift/Ctrl variants) app-launch
      # hotkeys default on and collide with the workspace-switching binds
      # below -- it only steals a given number if a dock slot is actually
      # occupied, which is why this silently broke just the low-numbered
      # workspaces rather than all of them. Our own binds own this
      # shortcut space, so dash-to-dock's copy is turned off.
      hot-keys = false;
    };

    "org/gnome/shell/extensions/caffeine" = {
      toggle-shortcut = [ "<Super>c" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];

      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-6 = [ "<Shift><Super>6" ];
      move-to-workspace-7 = [ "<Shift><Super>7" ];
      move-to-workspace-8 = [ "<Shift><Super>8" ];
      move-to-workspace-9 = [ "<Shift><Super>9" ];
    };

    # Free Super+1 ... Super+9 from GNOME Shell's application launcher
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
    };
  };
}
