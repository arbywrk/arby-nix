{ pkgs, ... }:

let
  # GNOME Shell's own default dark stylesheet, extracted straight out of
  # its own compiled gresource bundle -- same `gresource extract
  # gnome-shell-theme.gresource /org/gnome/shell/theme/gnome-shell-dark
  # .css` used by hand while developing this theme, just as a derivation
  # now so it tracks whatever gnome-shell version is actually installed
  # instead of a stale copy committed to this repo. This becomes
  # _generated-base.css below -- imported first by files/gnome-shell/
  # gnome-shell.css so every hand-written override in the other files
  # wins the cascade on top of it, exactly like it did while hand-editing
  # the live theme directory.
  gnomeShellBaseCss = pkgs.runCommand "gnome-shell-dark-base.css" { } ''
    ${pkgs.glib.dev}/bin/gresource extract \
      ${pkgs.gnome-shell}/share/gnome-shell/gnome-shell-theme.gresource \
      /org/gnome/shell/theme/gnome-shell-dark.css > $out
  '';
in

{
  home.packages = [
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.dash-to-dock
    pkgs.morewaita-icon-theme
    pkgs.papirus-icon-theme
    pkgs.loupe # GNOME's default image viewer
  ];

  # Widget theme is plain Adwaita now, not Yaru -- decided against Yaru's
  # own GTK theme entirely in favor of hand-tweaking stock libadwaita's
  # colors instead (see below). Icons/cursor stay as they were (a
  # separate concern from color scheme -- icon coverage/shape, not
  # widget-chrome color).
  #
  # Icons are "Yaruwaita" (defined below) -- not plain MoreWaita or Yaru.
  # Yaru's own icon set doesn't track GNOME's accent-color setting (its
  # per-accent variants like Yaru-blue/Yaru-olive are static picks, not
  # something that follows the live accent-color setting -- there's no
  # built-in link between the two, and building one would mean exactly the
  # kind of watcher this repo already decided against), so pure Yaru
  # looked out of sync. MoreWaita (github.com/somepaulo/MoreWaita) fixes
  # that (no accent identity of its own, wide extra app/mimetype coverage)
  # but has no generic places icons of its own (no folder.svg/user-home
  # .svg/etc, checked directly, only per-app folder variants like
  # "bitwig-project-folder") and no symbolic/status-area icons either --
  # e.g. the caffeine extension's tray icon needs those. Papirus fills
  # both of those gaps (its own folder icons -- plain default/MoreWaita
  # look, not Yaru's -- plus proper symbolic coverage), so it's next in
  # the chain. Tried also copying Yaru's own folder icons in on top at one
  # point (see git history); explicitly undone since a plain
  # MoreWaita/Papirus-derived folder look is what's wanted now.
  gtk = {
    enable = true;
    iconTheme = {
      name = "Yaruwaita";
      package = null; # no package of its own, see xdg.dataFile below
    };
    cursorTheme = {
      name = "Yaru"; # one cursor set covers both light and dark
      package = pkgs.yaru-theme;
      size = 24;
    };
    colorScheme = "dark";

    # No gtk4.extraCss here anymore -- that option manages
    # $XDG_CONFIG_HOME/gtk-4.0/gtk.css as a nix-store symlink, which meant
    # every color tweak needed a full rebuild+switch to test. For now
    # that file is a plain writable file instead (not managed by
    # home-manager), seeded with the same @define-color overrides this
    # option used to generate, so it can be hand-edited and reloaded
    # (kill/restart the app) without touching nix at all. Once the colors
    # are settled, bring the final values back here as gtk4.extraCss.
  };

  xdg.dataFile."icons/Yaruwaita/index.theme".text = ''
    [Icon Theme]
    Name=Yaruwaita
    Comment=MoreWaita's app/mimetype coverage, Papirus's folder/places and symbolic/status icons for everything else -- no icon files of its own.
    Inherits=MoreWaita,Papirus-Dark,Humanity,Adwaita,AdwaitaLegacy,hicolor
    Directories=
  '';

  # GNOME Shell theme "Custom" -- a from-scratch dark-mode color/roundness
  # pass over stock Adwaita (not Yaru's own shell theme), split into one
  # file per UI area for navigability rather than one huge stylesheet --
  # see files/gnome-shell/gnome-shell.css's own header comment for the
  # full rundown (color legend, table of contents, how to hand-edit and
  # reload this after a `home-manager switch`). _generated-base.css is
  # the one file here that ISN'T a plain source file -- see
  # gnomeShellBaseCss above, it's extracted fresh from the installed
  # gnome-shell package at build time instead of committed to this repo.
  xdg.dataFile."themes/Custom/gnome-shell/_generated-base.css".source = gnomeShellBaseCss;
  xdg.dataFile."themes/Custom/gnome-shell/gnome-shell.css".source = ./files/gnome-shell/gnome-shell.css;
  xdg.dataFile."themes/Custom/gnome-shell/popups.css".source = ./files/gnome-shell/popups.css;
  xdg.dataFile."themes/Custom/gnome-shell/buttons.css".source = ./files/gnome-shell/buttons.css;
  xdg.dataFile."themes/Custom/gnome-shell/quick-settings.css".source = ./files/gnome-shell/quick-settings.css;
  xdg.dataFile."themes/Custom/gnome-shell/calendar.css".source = ./files/gnome-shell/calendar.css;
  xdg.dataFile."themes/Custom/gnome-shell/notifications.css".source = ./files/gnome-shell/notifications.css;
  xdg.dataFile."themes/Custom/gnome-shell/top-bar.css".source = ./files/gnome-shell/top-bar.css;
  xdg.dataFile."themes/Custom/gnome-shell/overview.css".source = ./files/gnome-shell/overview.css;
  xdg.dataFile."themes/Custom/gnome-shell/modals.css".source = ./files/gnome-shell/modals.css;

  # A tiny local extension (not a nixpkgs/extensions.gnome.org package --
  # see files/gnome-shell-extensions/hide-dark-style/extension.js for why)
  # that hides the built-in "Dark Style" quick-settings toggle, which has
  # no use now that color-scheme is pinned to prefer-dark below. Its uuid
  # (and hence its real install path, .../extensions/hide-dark-style@arby-nix/)
  # is "hide-dark-style@arby-nix" per metadata.json -- the source directory
  # itself is named without the "@" only because Nix path literals can't
  # contain one unescaped.
  xdg.dataFile."gnome-shell/extensions/hide-dark-style@arby-nix/metadata.json".source =
    ./files/gnome-shell-extensions/hide-dark-style/metadata.json;
  xdg.dataFile."gnome-shell/extensions/hide-dark-style@arby-nix/extension.js".source =
    ./files/gnome-shell-extensions/hide-dark-style/extension.js;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      accent-color = "blue"; # GNOME's own default

      # Locked to dark: GNOME's own User Themes extension has no concept
      # of light/dark at all (verified by reading its extension.js --
      # `_changeTheme()` only reacts to the theme *name* setting, never to
      # this color-scheme key), so once a custom shell theme is active
      # the system light/dark switch stops affecting shell chrome
      # entirely -- there's no native way to make it do both. Rather than
      # add a watcher to fake that reactivity (exactly the kind of
      # bespoke live-sync this repo avoids elsewhere), going dark-only:
      # this key is pinned so GTK4/libadwaita apps that read it live stay
      # consistent with the shell, and the now-pointless "Dark Style"
      # quick-settings toggle is hidden (see hide-dark-style@arby-nix
      # below).
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell" = {
      # Caffeine: toggleable "prevent idle/suspend" -- click the mug icon in
      # the top bar, or right-click it for a timed duration.
      #
      # user-theme: lets GNOME Shell's own chrome (top bar, overview) pick
      # up a custom shell theme by name -- vanilla GNOME Shell otherwise
      # ignores shell themes entirely without this extension. Active theme
      # name is "Custom" (see the dconf key below), backed by the files
      # under xdg.dataFile "themes/Custom/gnome-shell/*" further up.
      #
      # dash-to-dock: Ubuntu-style dock instead of GNOME's built-in
      # (non-auto-hiding) dash. Configured below to sit on the bottom edge
      # and auto-hide so it doesn't eat screen real estate.
      #
      # hide-dark-style: local extension (see files/gnome-shell-extensions/
      # hide-dark-style@arby-nix/) hiding the now-useless "Dark Style"
      # toggle -- dark-only per the color-scheme lock above. Its own
      # metadata.json declares the actual installed shell-version (50), so
      # unlike the third-party extension this replaced, it needs no
      # disable-extension-version-validation escape hatch.
      enabled-extensions = [
        "caffeine@patapon.info"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "hide-dark-style@arby-nix"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Custom";
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

      # Match the rest of the color pass (see files/gnome-shell/*.css) --
      # dash-to-dock's own background isn't part of the gnome-shell.css
      # theme at all (it paints itself independently of the shell theme's
      # popup-menu-content/etc surfaces), so it needs these set directly
      # rather than picking the color up automatically. "FIXED" transparency
      # mode is required for background-opacity to actually take effect as
      # a constant value -- the default "DEFAULT" mode dynamically adjusts
      # opacity based on window proximity instead of honoring this.
      custom-background-color = true;
      background-color = "#1d1d1d";
      transparency-mode = "FIXED";
      background-opacity = 0.8;
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
