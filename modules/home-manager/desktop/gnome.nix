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

  # Widget theme is plain Adwaita -- hand-tweaking stock libadwaita's
  # colors instead of pulling in a whole third-party GTK theme (see
  # below). Icons/cursor are a separate concern from color scheme (icon
  # coverage/shape, not widget-chrome color); no Yaru anywhere in this
  # config anymore -- neither the old "Yaruwaita" icon-theme name (never
  # an actual dependency, see "Waitapirus" below) nor the old Yaru cursor
  # package.
  #
  # Icons are "Waitapirus" (defined below) -- not plain MoreWaita or
  # Papirus alone. MoreWaita (github.com/somepaulo/MoreWaita) tracks
  # GNOME's own accent-color setting (no fixed accent identity baked into
  # its icons, unlike e.g. Yaru's static per-accent variants such as
  # Yaru-blue/Yaru-olive, which don't follow the live accent-color
  # setting at all -- there's no built-in link between the two, and
  # building one would mean exactly the kind of watcher this repo already
  # decided against) and has wide extra app/mimetype coverage, but has no
  # generic places icons of its own (no folder.svg/user-home.svg/etc,
  # checked directly, only per-app folder variants like
  # "bitwig-project-folder") and no symbolic/status-area icons either --
  # e.g. the caffeine extension's tray icon needs those. Papirus fills
  # both of those gaps (its own folder/symbolic icon coverage), so it's
  # next in the inheritance chain.
  gtk = {
    enable = true;
    iconTheme = {
      name = "Waitapirus";
      package = null; # no package of its own, see xdg.dataFile below
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice"; # light cursor, reads well on the dark theme below
      package = pkgs.bibata-cursors;
      size = 24;
    };
    colorScheme = "dark";

    # Every named color libadwaita apps (Settings, Nautilus, Loupe, ...)
    # read live, not just the ones this repo actually changed -- so the
    # full palette is visible and editable in one place later. Each line
    # says CUSTOM (with why) or DEFAULT (libadwaita 1.9's own dark-mode
    # value, restated verbatim so this is a genuine no-op, not a frozen
    # snapshot -- some defaults are themselves aliases like
    # "@window_bg_color" or relative functions like oklab(...), and
    # hardcoding a *resolved* number for those would silently stop
    # tracking whatever they alias once that other color changes).
    # Verified by extracting /org/gnome/Adwaita/styles/gtk.css out of the
    # installed libadwaita-1.so via gresource.
    #
    # Deliberately NOT listed: accent_color/accent_bg_color/
    # accent_fg_color and the destructive/success/warning/error_*
    # semantic colors. Accent reads live from
    # org/gnome/desktop/interface accent-color (same as the shell's own
    # -st-accent-color) and isn't even in this static stylesheet --
    # AdwStyleManager injects it at runtime. The semantic colors carry
    # meaning (destructive action, error state, ...), not "look", so
    # they're out of scope for a surface-color pass.
    #
    # Was a plain hand-edited $XDG_CONFIG_HOME/gtk-4.0/gtk.css (not
    # home-manager-managed) while iterating on these colors against
    # Settings/Nautilus/Loupe, since gtk4.extraCss needs a full
    # rebuild+switch (and an app restart -- GTK4 doesn't hot-reload this
    # file either way) to see a change. Moved here now that the values
    # are settled.
    gtk4.extraCss = ''
      /* Main window surfaces. CUSTOM: darker greys/blacks, no purple
         tint, reusing the shell theme's own two tones (see
         files/gnome-shell/gnome-shell.css) so everything reads as one
         theme -- #1d1d1d for recessed content (same as the shell's
         popup/dropdown surfaces), #303030 for raised chrome (same as
         the shell's buttons/pills/cards). Foreground #F7F7F7 (a touch
         off pure white) matches what this config already used
         everywhere before this pass, restated here rather than changed.
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
         tracking window_bg_color above (currently resolves to our
         #303030) instead of freezing to libadwaita's own #222226. This
         is what an unfocused window's headerbar fades to. */
      @define-color headerbar_backdrop_color @window_bg_color;
      /* DEFAULT: subtle drop-shadow-style darkening under the headerbar
         (36%) and an even darker one some widgets use for emphasis
         (90%) -- both alpha-based, so they auto-adapt to whatever's
         under them regardless of the surface colors above. */
      @define-color headerbar_shade_color RGB(0 0 6 / 36%);
      @define-color headerbar_darker_shade_color RGB(0 0 12 / 90%);

      /* CUSTOM: sidebar (Nautilus's places list, Settings' category
         list) matches the #303030 chrome tone too -- same reasoning as
         headerbar above. backdrop/secondary tones nudged one step
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
      /* DEFAULT: not customized -- Nautilus's second-level sidebar
         (e.g. its tag list) isn't something this pass looked at. */
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
         CUSTOM: darker #1d1d1d -- same reasoning the shell's
         modals.css already used for its own .modal-dialog: "this is
         functionally a popup surface too, just modal instead of a
         dropdown". DEFAULT: #36363a/white. */
      @define-color dialog_bg_color #1d1d1d;
      @define-color dialog_fg_color #F7F7F7;

      /* DEFAULT, left alone: card_bg_color is a translucent white
         overlay (8%), not a literal color -- a relative "lighten
         whatever's underneath" mix, so it already adapts correctly to
         window_bg_color above without needing its own override. Same
         reasoning for its shade/foreground. */
      @define-color card_bg_color RGB(255 255 255 / 8%);
      @define-color card_fg_color white;
      @define-color card_shade_color RGB(0 0 6 / 36%);

      /* DEFAULT: image/file thumbnail backing (e.g. behind a
         letterboxed image in Loupe or a file-manager preview) --
         Loupe's own actual image canvas is view_bg_color above, not
         this; not customized. */
      @define-color thumbnail_bg_color #39393d;
      @define-color thumbnail_fg_color white;

      /* DEFAULT: generic overlay-darkening used in a handful of odd
         corners (e.g. some dimmed/disabled overlays) and the outline
         GTK draws around scrollbars over content -- both alpha-based. */
      @define-color shade_color RGB(0 0 6 / 25%);
      @define-color scrollbar_outline_color RGB(0 0 12 / 95%);
    '';

    # GTK3-era named colors (legacy/GTK3-only apps -- most of what's
    # actually visible day-to-day, Settings/Nautilus/Loupe, is GTK4 and
    # reads gtk4.extraCss above instead). Full palette, same CUSTOM/
    # DEFAULT convention as gtk4.extraCss above. DEFAULT values verified
    # by extracting /org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css
    # out of the installed libgtk-3.so via gresource -- GTK3's Adwaita
    # theme is compiled straight into libgtk-3 itself, no separate
    # package. Not listed: warning_color/error_color/success_color
    # (semantic, same reasoning as gtk4.extraCss's exclusions) and the
    # wm_*/content_view_bg/text_view_bg families (window-manager
    # decoration internals and Yaru-specific extensions stock Adwaita-3
    # never reads -- out of scope here).
    gtk3.extraCss = ''
      /* Main surfaces. CUSTOM: same two shell-matching tones as
         gtk4.extraCss -- #303030 chrome (theme_bg_color), #1d1d1d
         recessed content (theme_base_color, entry/list/textview
         backgrounds). theme_text_color restated at this config's usual
         #F7F7F7 rather than changed. DEFAULT: theme_fg_color #eeeeec,
         theme_text_color white, theme_bg_color #353535,
         theme_base_color #2d2d2d. */
      @define-color theme_bg_color #303030;
      @define-color theme_fg_color #F7F7F7;
      @define-color theme_base_color #1d1d1d;
      @define-color theme_text_color #F7F7F7;

      /* Unfocused-window variants. CUSTOM: alpha-based dimming (65%)
         instead of libadwaita's flat muted grey, so it tracks whatever
         the focused foreground color above is instead of being a
         separate fixed pick; backgrounds one step darker than their
         focused counterparts, same relative feel as the sidebar_backdrop
         treatment in gtk4.extraCss. DEFAULT: theme_unfocused_fg_color
         #919190 (flat, not alpha), theme_unfocused_text_color white,
         theme_unfocused_bg_color #353535, theme_unfocused_base_color
         #303030. */
      @define-color theme_unfocused_bg_color #262626;
      @define-color theme_unfocused_fg_color rgba(247, 247, 247, 0.65);
      @define-color theme_unfocused_base_color #1a1a1a;
      @define-color theme_unfocused_text_color rgba(247, 247, 247, 0.65);

      /* CUSTOM: darker to match theme_base_color's #1d1d1d neighborhood
         instead of libadwaita's own lighter greys.
         DEFAULT: insensitive_bg_color #323232, insensitive_fg_color
         #919190, insensitive_base_color #2d2d2d. */
      @define-color insensitive_bg_color #262626;
      @define-color insensitive_fg_color #929292;
      @define-color insensitive_base_color #1a1a1a;

      /* GTK3 has no live accent-color setting -- that's a GTK4/
         libadwaita-only feature (confirmed: Adwaita-3's own gtk.css
         hardcodes its selection color, never reads
         org/gnome/desktop/interface accent-color). CUSTOM: static pick
         matching the current accent-color = "blue" default set below --
         if that's ever changed, this needs a matching manual update,
         same tradeoff already accepted for ghostty's pinned-dark theme.
         theme_selected_fg_color happens to already equal libadwaita's
         own default (#ffffff); restated for visibility, not a real
         change. DEFAULT: theme_selected_bg_color #15539e. */
      @define-color theme_selected_bg_color #3584e4;
      @define-color theme_selected_fg_color #FFFFFF;
      /* DEFAULT, left alone: same accent used for an unfocused window's
         selection -- diverges from theme_selected_bg_color above since
         only the focused one was customized. Revisit together if this
         ever looks inconsistent. */
      @define-color theme_unfocused_selected_bg_color #15539e;
      @define-color theme_unfocused_selected_fg_color #ffffff;
      /* DEFAULT: muted grey used sparingly (e.g. unfocused+insensitive
         text) -- not customized. */
      @define-color unfocused_insensitive_color #5b5b5b;

      /* Hairline dividers. CUSTOM: Yaru-dark's own real values
         (verified via `gresource extract` on its gtk-3.0/gtk.gresource
         -- not stock Adwaita-3, whose own default is a less
         near-black #1b1b1b/#202020), reused directly since they're
         already exactly the near-black tone this pass wants. */
      @define-color borders #131313;
      @define-color unfocused_borders #181818;
    '';
  };

  xdg.dataFile."icons/Waitapirus/index.theme".text = ''
    [Icon Theme]
    Name=Waitapirus
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

      # GNOME Shell/Mutter (the desktop cursor and window-manager chrome,
      # as opposed to individual GTK apps) reads these -- NOT gtk.iconTheme
      # /gtk.cursorTheme above, which only cover settings.ini for GTK apps
      # themselves. Both keys were already sitting in this dconf database
      # with stray live values ('Yaruwaita', 'Yaru') that this repo never
      # actually declared (same situation as button-layout below) -- made
      # explicit here so a fresh profile doesn't silently fall back to
      # GNOME's own Adwaita/Adwaita defaults instead.
      icon-theme = "Waitapirus";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 24;
    };

    "org/gnome/desktop/wm/preferences" = {
      # Drops the small app icon GTK's CSD titlebar draws top-left of every
      # window -- was "icon:minimize,maximize,close" (checked live via
      # `gsettings get`; not something this repo had ever set, so likely a
      # stray Ubuntu/Yaru-session-derived default already in this dconf
      # database), same minimize/maximize/close ordering otherwise, just
      # without the leading "icon:".
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
