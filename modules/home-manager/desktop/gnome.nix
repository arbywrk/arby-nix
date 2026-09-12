{ pkgs, ... }:

let
  # GNOME Shell's own default dark stylesheet, pulled straight out of its
  # compiled gresource bundle so it tracks whatever gnome-shell version is
  # actually installed instead of a stale copy committed to this repo.
  # Becomes _generated-base.css below, imported first by
  # files/gnome-shell/gnome-shell.css so every override in the other files
  # wins the cascade on top of it.
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
    pkgs.papirus-icon-theme
    pkgs.loupe # GNOME's default image viewer
  ];

  # Widget theme is plain Adwaita, hand-tweaked below instead of pulling
  # in a third-party GTK theme. Icons are Papirus-Dark, wrapped under the
  # name "PapirusPlus" so a couple of directories stay reserved for
  # swapping individual icons later (see the empty xdg.dataFile block
  # below) without touching iconTheme.name again.
  gtk = {
    enable = true;
    iconTheme = {
      name = "PapirusPlus";
      package = null; # no package of its own, see xdg.dataFile below
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice"; # light cursor, reads well on the dark theme below
      package = pkgs.bibata-cursors;
      size = 24;
    };
    colorScheme = "dark";

    # Every named color libadwaita apps (Settings, Nautilus, Loupe, ...)
    # read live is listed here, not just the ones actually changed, so
    # the full palette stays visible and editable in one place. Each
    # line is marked CUSTOM (with why) or DEFAULT (libadwaita's own
    # dark-mode value, restated as-is rather than as a resolved number --
    # some defaults are aliases like "@window_bg_color" or relative
    # functions like oklab(...) that need to keep tracking whatever they
    # alias, not freeze to today's snapshot).
    #
    # Accent (accent_color/accent_bg_color/accent_fg_color) and the
    # destructive/success/warning/error_* semantic colors are left out
    # entirely: accent reads live from org/gnome/desktop/interface
    # accent-color (same as the shell's own -st-accent-color) and isn't
    # even part of this static stylesheet -- AdwStyleManager injects it
    # at runtime. The semantic colors carry meaning, not look, so they're
    # out of scope for a surface-color pass.
    gtk4.extraCss = ''
      /* Main window surfaces. CUSTOM: darker greys/blacks, no purple
         tint, reusing the shell theme's own two tones (see
         files/gnome-shell/gnome-shell.css) so everything reads as one
         theme -- #1d1d1d for recessed content (same as the shell's
         popup/dropdown surfaces), #303030 for raised chrome (same as
         the shell's buttons/pills/cards). Foreground #F7F7F7 (a touch
         off pure white) matches the rest of this config.
         DEFAULT (libadwaita): window_bg_color #222226, window_fg_color/
         view_fg_color white, view_bg_color #1d1d20. */
      @define-color window_bg_color #303030;
      @define-color window_fg_color #F7F7F7;
      @define-color view_bg_color #1d1d1d;
      @define-color view_fg_color #F7F7F7;

      /* CUSTOM: same #303030 chrome tone as window_bg_color above, so
         the headerbar doesn't stand out from the window it's attached
         to (Yaru-esque flat look). DEFAULT: #2e2e32/white. */
      @define-color headerbar_bg_color #303030;
      @define-color headerbar_fg_color #F7F7F7;
      /* DEFAULT: white -- a translucent top-edge highlight line, not a
         flat fill; left alone. */
      @define-color headerbar_border_color white;
      /* DEFAULT: an alias, not a literal -- restated as one so it keeps
         tracking window_bg_color above (currently #303030) instead of
         freezing to libadwaita's own #222226. This is what an unfocused
         window's headerbar fades to. */
      @define-color headerbar_backdrop_color @window_bg_color;
      /* DEFAULT: subtle drop-shadow-style darkening under the headerbar
         (36%) and an even darker one some widgets use for emphasis
         (90%) -- both alpha-based, so they auto-adapt to whatever's
         under them regardless of the surface colors above. */
      @define-color headerbar_shade_color RGB(0 0 6 / 36%);
      @define-color headerbar_darker_shade_color RGB(0 0 12 / 90%);

      /* CUSTOM: sidebar (Nautilus's places list, Settings' category
         list) matches the #303030 chrome tone too, same reasoning as
         headerbar above. Backdrop/secondary tones nudged one step
         darker each to keep their relative "one step down" feel instead
         of inheriting libadwaita's own purple-tinted numbers verbatim.
         DEFAULT: sidebar_bg/fg #2e2e32/white, sidebar_backdrop #28282c,
         secondary_sidebar_bg #28282c, secondary_sidebar_backdrop
         #252529. */
      @define-color sidebar_bg_color #303030;
      @define-color sidebar_fg_color #F7F7F7;
      @define-color sidebar_backdrop_color #262626;
      @define-color secondary_sidebar_bg_color #262626;
      @define-color secondary_sidebar_backdrop_color #202020;
      /* DEFAULT: Nautilus's second-level sidebar (e.g. its tag list)
         isn't part of this pass. */
      @define-color secondary_sidebar_fg_color white;
      /* DEFAULT: alpha-based edge/shadow accents on the sidebar
         boundary, same reasoning as headerbar_shade_color above. */
      @define-color sidebar_shade_color RGB(0 0 6 / 25%);
      @define-color sidebar_border_color RGB(0 0 6 / 36%);
      @define-color secondary_sidebar_shade_color RGB(0 0 6 / 25%);
      @define-color secondary_sidebar_border_color RGB(0 0 6 / 36%);

      /* Popovers/menus (e.g. Nautilus's right-click menu, Settings'
         dropdowns). CUSTOM: same #303030 chrome tone, matching the
         shell's own .quick-toggle-menu resting background.
         DEFAULT: #36363a/white. */
      @define-color popover_bg_color #303030;
      @define-color popover_fg_color #F7F7F7;
      /* DEFAULT: alpha-based inner shading, adapts automatically. */
      @define-color popover_shade_color RGB(0 0 6 / 25%);

      /* Dialogs (file choosers, "Delete"/"Replace" confirmations).
         CUSTOM: darker #1d1d1d, same treatment the shell's modals.css
         gives its own .modal-dialog -- a modal is just a popup surface
         that happens to be modal. DEFAULT: #36363a/white. */
      @define-color dialog_bg_color #1d1d1d;
      @define-color dialog_fg_color #F7F7F7;

      /* DEFAULT, left alone: card_bg_color is a translucent white
         overlay (8%), not a literal color -- a relative "lighten
         whatever's underneath" mix, so it already adapts to
         window_bg_color above without its own override. Same for its
         shade/foreground. */
      @define-color card_bg_color RGB(255 255 255 / 8%);
      @define-color card_fg_color white;
      @define-color card_shade_color RGB(0 0 6 / 36%);

      /* DEFAULT: image/file thumbnail backing (e.g. behind a
         letterboxed image in Loupe or a file-manager preview) --
         Loupe's actual image canvas is view_bg_color above, not this. */
      @define-color thumbnail_bg_color #39393d;
      @define-color thumbnail_fg_color white;

      /* DEFAULT: generic overlay-darkening for a handful of odd corners
         (e.g. dimmed/disabled overlays) and the outline GTK draws
         around scrollbars over content -- both alpha-based. */
      @define-color shade_color RGB(0 0 6 / 25%);
      @define-color scrollbar_outline_color RGB(0 0 12 / 95%);
    '';

    # GTK3-era named colors -- most of what's actually visible day to
    # day (Settings, Nautilus, Loupe) is GTK4 and reads gtk4.extraCss
    # above instead. Full palette, same CUSTOM/DEFAULT convention.
    # DEFAULT values are Adwaita-3's own dark-mode palette, compiled
    # directly into libgtk-3 -- there's no separate GTK3 theme package.
    # Not listed: warning_color/error_color/success_color (semantic,
    # same reasoning as gtk4.extraCss's exclusions above) and the
    # wm_*/content_view_bg/text_view_bg families (window-manager
    # decoration internals and Yaru-specific extensions stock Adwaita-3
    # never reads).
    gtk3.extraCss = ''
      /* Main surfaces. CUSTOM: same two shell-matching tones as
         gtk4.extraCss -- #303030 chrome (theme_bg_color), #1d1d1d
         recessed content (theme_base_color, entry/list/textview
         backgrounds). theme_text_color restated at this config's usual
         #F7F7F7. DEFAULT: theme_fg_color #eeeeec, theme_text_color
         white, theme_bg_color #353535, theme_base_color #2d2d2d. */
      @define-color theme_bg_color #303030;
      @define-color theme_fg_color #F7F7F7;
      @define-color theme_base_color #1d1d1d;
      @define-color theme_text_color #F7F7F7;

      /* Unfocused-window variants. CUSTOM: alpha-based dimming (65%)
         instead of libadwaita's flat muted grey, so it tracks the
         focused foreground color above instead of being a separate
         fixed pick; backgrounds one step darker than their focused
         counterparts, same relative feel as sidebar_backdrop in
         gtk4.extraCss. DEFAULT: theme_unfocused_fg_color #919190
         (flat, not alpha), theme_unfocused_text_color white,
         theme_unfocused_bg_color #353535, theme_unfocused_base_color
         #303030. */
      @define-color theme_unfocused_bg_color #262626;
      @define-color theme_unfocused_fg_color rgba(247, 247, 247, 0.65);
      @define-color theme_unfocused_base_color #1a1a1a;
      @define-color theme_unfocused_text_color rgba(247, 247, 247, 0.65);

      /* CUSTOM: darker, to match theme_base_color's #1d1d1d
         neighborhood instead of libadwaita's own lighter greys.
         DEFAULT: insensitive_bg_color #323232, insensitive_fg_color
         #919190, insensitive_base_color #2d2d2d. */
      @define-color insensitive_bg_color #262626;
      @define-color insensitive_fg_color #929292;
      @define-color insensitive_base_color #1a1a1a;

      /* GTK3 has no live accent-color setting -- that's a GTK4/
         libadwaita-only feature, Adwaita-3's own gtk.css hardcodes its
         selection color instead. CUSTOM: static pick matching the
         accent-color = "blue" default set below -- if that ever
         changes, this needs a matching manual update, same tradeoff
         already accepted for ghostty's pinned-dark theme.
         theme_selected_fg_color already equals libadwaita's own default
         (#ffffff), restated here for visibility rather than changed.
         DEFAULT: theme_selected_bg_color #15539e. */
      @define-color theme_selected_bg_color #3584e4;
      @define-color theme_selected_fg_color #FFFFFF;
      /* DEFAULT, left alone: same accent used for an unfocused window's
         selection -- diverges from theme_selected_bg_color above since
         only the focused one was customized. Revisit together if that
         ever looks inconsistent. */
      @define-color theme_unfocused_selected_bg_color #15539e;
      @define-color theme_unfocused_selected_fg_color #ffffff;
      /* DEFAULT: muted grey used sparingly (e.g. unfocused+insensitive
         text). */
      @define-color unfocused_insensitive_color #5b5b5b;

      /* Hairline dividers. CUSTOM: Yaru-dark's own values, not stock
         Adwaita-3's less near-black #1b1b1b/#202020 -- already exactly
         the near-black tone this pass wants. */
      @define-color borders #131313;
      @define-color unfocused_borders #181818;
    '';
  };

  # Per-icon override slot, deliberately empty -- Papirus-Dark's own
  # trash/settings icons are used for now. This block, and the
  # scalable/places + scalable/apps directories index.theme declares
  # below, exist so a specific icon can be swapped in later without any
  # more wiring: add an entry shaped like the commented examples and it
  # wins over Papirus-Dark outright.
  #
  # xdg.dataFile."icons/PapirusPlus/scalable/places/user-trash.svg".source =
  #   "${pkgs.SOME_ICON_THEME}/share/icons/SOME_THEME/.../user-trash.svg";
  # xdg.dataFile."icons/PapirusPlus/scalable/places/user-trash-full.svg".source =
  #   "${pkgs.SOME_ICON_THEME}/share/icons/SOME_THEME/.../user-trash-full.svg";
  # xdg.dataFile."icons/PapirusPlus/scalable/apps/org.gnome.Settings.svg".source =
  #   "${pkgs.SOME_ICON_THEME}/share/icons/SOME_THEME/.../preferences-system.svg";
  # xdg.dataFile."icons/PapirusPlus/scalable/apps/preferences-system.svg".source =
  #   "${pkgs.SOME_ICON_THEME}/share/icons/SOME_THEME/.../preferences-system.svg";

  xdg.dataFile."icons/PapirusPlus/index.theme".text = ''
    [Icon Theme]
    Name=PapirusPlus
    Comment=Papirus-Dark, with an empty override slot for individual icons (see the xdg.dataFile comment above).
    Inherits=Papirus-Dark,hicolor
    Directories=scalable/places,scalable/apps

    [scalable/places]
    Size=48
    MinSize=8
    MaxSize=512
    Type=Scalable
    Context=Places

    [scalable/apps]
    Size=48
    MinSize=8
    MaxSize=512
    Type=Scalable
    Context=Applications
  '';

  # GNOME Shell theme "Custom" -- a from-scratch dark-mode color/roundness
  # pass over stock Adwaita, not Yaru's own shell theme, split into one
  # file per UI area for navigability rather than one huge stylesheet --
  # see files/gnome-shell/gnome-shell.css's own header comment for the
  # full rundown (color legend, table of contents, how to hand-edit and
  # reload this after a `home-manager switch`). _generated-base.css is
  # the one file here that isn't a plain source file -- see
  # gnomeShellBaseCss above, extracted fresh from the installed
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
  # that hides the built-in "Dark Style" quick-settings toggle, pointless
  # now that color-scheme is pinned to prefer-dark below. Its uuid (and
  # hence its real install path,
  # .../extensions/hide-dark-style@arby-nix/) is "hide-dark-style@arby-nix"
  # per metadata.json -- the source directory itself is named without the
  # "@" only because Nix path literals can't contain one unescaped.
  xdg.dataFile."gnome-shell/extensions/hide-dark-style@arby-nix/metadata.json".source =
    ./files/gnome-shell-extensions/hide-dark-style/metadata.json;
  xdg.dataFile."gnome-shell/extensions/hide-dark-style@arby-nix/extension.js".source =
    ./files/gnome-shell-extensions/hide-dark-style/extension.js;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      accent-color = "blue"; # GNOME's own default

      # GNOME's own User Themes extension has no concept of light/dark
      # at all -- it only reacts to the theme *name* setting, never to
      # this key -- so once a custom shell theme is active, the system
      # light/dark switch stops affecting shell chrome entirely. Pinned
      # to dark instead of building a watcher to fake that reactivity:
      # keeps GTK4/libadwaita apps visually consistent with the shell,
      # and makes the "Dark Style" quick-settings toggle pointless
      # (hidden via hide-dark-style@arby-nix below).
      color-scheme = "prefer-dark";

      # GNOME Shell/Mutter (the desktop cursor and window-manager chrome,
      # as opposed to individual GTK apps) reads these -- not
      # gtk.iconTheme/gtk.cursorTheme above, which only cover
      # settings.ini for GTK apps themselves. Both keys were already
      # sitting in this dconf database with stray live values
      # ('Yaruwaita', 'Yaru') this repo never actually declared (same
      # situation as button-layout below) -- made explicit here so a
      # fresh profile doesn't fall back to GNOME's own defaults instead.
      icon-theme = "PapirusPlus";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 24;
    };

    "org/gnome/desktop/wm/preferences" = {
      # Drops the small app icon GTK's CSD titlebar draws top-left of
      # every window. Default was "icon:minimize,maximize,close", a
      # stray value already in this dconf database (not something this
      # config had set, likely left over from an Ubuntu/Yaru session
      # default) -- same minimize/maximize/close ordering otherwise,
      # just without the leading "icon:".
      button-layout = ":minimize,maximize,close";
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
      # metadata.json declares the actual installed shell-version (50),
      # so it needs no disable-extension-version-validation escape hatch.
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
      # hotkeys collide with the workspace-switching binds below -- it
      # only steals a number if a dock slot is actually occupied, which
      # is why this broke just the low-numbered workspaces rather than
      # all of them. Our own binds own this shortcut space, so
      # dash-to-dock's copy is turned off.
      hot-keys = false;

      # Matches the rest of the color pass (see files/gnome-shell/*.css)
      # -- dash-to-dock paints its own background independently of the
      # shell theme's popup-menu-content surfaces, so it needs these set
      # directly. "FIXED" transparency mode is required for
      # background-opacity to actually take effect as a constant value
      # -- the default "DEFAULT" mode adjusts opacity based on window
      # proximity instead.
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
