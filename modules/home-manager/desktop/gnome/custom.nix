{ lib, pkgs, ... }:

let
  # GNOME Shell's default dark stylesheet, extracted from its compiled
  # gresource bundle so it tracks the installed gnome-shell version
  # instead of a stale copy committed here. Becomes _generated-base.css
  # below, imported first so every override wins the cascade on top of it.
  gnomeShellBaseCss = pkgs.runCommand "gnome-shell-dark-base.css" { } ''
    ${pkgs.glib.dev}/bin/gresource extract \
      ${pkgs.gnome-shell}/share/gnome-shell/gnome-shell-theme.gresource \
      /org/gnome/shell/theme/gnome-shell-dark.css > $out
  '';
in

{
  # Functional bits (keybindings, apps, ...) live in ./default.nix -- this
  # file only adds look-and-feel on top. See ./README.md for the split.
  imports = [ ./default.nix ];

  home.packages = [
    pkgs.gnomeExtensions.user-themes
    pkgs.papirus-icon-theme
  ];

  # Widget theme is hand-tweaked Adwaita (below), not a third-party GTK
  # theme. Icons are Papirus-Dark wrapped as "PapirusPlus" so individual
  # icons can be swapped later (see the xdg.dataFile block below).
  # lib.mkForce: default.nix (imported above) already sets iconTheme.
  gtk = {
    enable = true;
    iconTheme = {
      name = lib.mkForce "PapirusPlus";
      package = lib.mkForce null; # no package of its own, see xdg.dataFile below
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice"; # light cursor, reads well on the dark theme below
      package = pkgs.bibata-cursors;
      size = 24;
    };
    colorScheme = "dark";

    # Full libadwaita named-color palette, not just what's changed, kept
    # in one place for editability. Each block notes CUSTOM values (and
    # why) or leaves libadwaita's own DEFAULT as-is. Accent and the
    # destructive/success/warning/error_* semantic colors are out of
    # scope: accent reads live from org/gnome/desktop/interface
    # accent-color, and semantic colors carry meaning, not look.
    gtk4.extraCss = ''
      /* Window surfaces: dark greys matching the shell's own popup
         (#1d1d1d) / chrome (#303030) tones. DEFAULT: window_bg #222226,
         view_bg #1d1d20. */
      @define-color window_bg_color #303030;
      @define-color window_fg_color #F7F7F7;
      @define-color view_bg_color #1d1d1d;
      @define-color view_fg_color #F7F7F7;

      /* Headerbar: same chrome tone as window_bg_color (flat, Yaru-esque).
         DEFAULT: #2e2e32/white. */
      @define-color headerbar_bg_color #303030;
      @define-color headerbar_fg_color #F7F7F7;
      @define-color headerbar_border_color white; /* DEFAULT */
      @define-color headerbar_backdrop_color @window_bg_color; /* DEFAULT, tracks window_bg_color */
      @define-color headerbar_shade_color RGB(0 0 6 / 36%); /* DEFAULT */
      @define-color headerbar_darker_shade_color RGB(0 0 12 / 90%); /* DEFAULT */

      /* Sidebar (Nautilus, Settings): same chrome tone, backdrop tones
         nudged one step darker each. DEFAULT: #2e2e32/white family. */
      @define-color sidebar_bg_color #303030;
      @define-color sidebar_fg_color #F7F7F7;
      @define-color sidebar_backdrop_color #262626;
      @define-color secondary_sidebar_bg_color #262626;
      @define-color secondary_sidebar_backdrop_color #202020;
      @define-color secondary_sidebar_fg_color white; /* DEFAULT */
      @define-color sidebar_shade_color RGB(0 0 6 / 25%); /* DEFAULT */
      @define-color sidebar_border_color RGB(0 0 6 / 36%); /* DEFAULT */
      @define-color secondary_sidebar_shade_color RGB(0 0 6 / 25%); /* DEFAULT */
      @define-color secondary_sidebar_border_color RGB(0 0 6 / 36%); /* DEFAULT */

      /* Popovers/menus: chrome tone, matches the shell's quick-toggle-menu.
         DEFAULT: #36363a/white. */
      @define-color popover_bg_color #303030;
      @define-color popover_fg_color #F7F7F7;
      @define-color popover_shade_color RGB(0 0 6 / 25%); /* DEFAULT */

      /* Dialogs: darker, matching the shell's own modal surfaces.
         DEFAULT: #36363a/white. */
      @define-color dialog_bg_color #1d1d1d;
      @define-color dialog_fg_color #F7F7F7;

      /* DEFAULT below -- alpha/relative values that already adapt to the
         surface colors above. */
      @define-color card_bg_color RGB(255 255 255 / 8%);
      @define-color card_fg_color white;
      @define-color card_shade_color RGB(0 0 6 / 36%);
      @define-color thumbnail_bg_color #39393d;
      @define-color thumbnail_fg_color white;
      @define-color shade_color RGB(0 0 6 / 25%);
      @define-color scrollbar_outline_color RGB(0 0 12 / 95%);
    '';

    # GTK3-era named colors -- most of what's visible day to day is GTK4
    # (gtk4.extraCss above); this covers what's still GTK3. Same
    # CUSTOM/DEFAULT convention; DEFAULT values are Adwaita-3's own,
    # compiled into libgtk-3. Semantic and window-manager-internal
    # families are left out, same reasoning as gtk4.extraCss.
    gtk3.extraCss = ''
      /* Main surfaces: same shell-matching tones as gtk4.extraCss.
         DEFAULT: theme_fg #eeeeec, theme_bg #353535, theme_base #2d2d2d. */
      @define-color theme_bg_color #303030;
      @define-color theme_fg_color #F7F7F7;
      @define-color theme_base_color #1d1d1d;
      @define-color theme_text_color #F7F7F7;

      /* Unfocused-window variants: alpha-based dimming instead of a flat
         grey, so it tracks the focused color above.
         DEFAULT: theme_unfocused_fg #919190, _bg #353535, _base #303030. */
      @define-color theme_unfocused_bg_color #262626;
      @define-color theme_unfocused_fg_color rgba(247, 247, 247, 0.65);
      @define-color theme_unfocused_base_color #1a1a1a;
      @define-color theme_unfocused_text_color rgba(247, 247, 247, 0.65);

      /* Darker, matching theme_base_color's neighborhood.
         DEFAULT: insensitive_bg #323232, _fg #919190, _base #2d2d2d. */
      @define-color insensitive_bg_color #262626;
      @define-color insensitive_fg_color #929292;
      @define-color insensitive_base_color #1a1a1a;

      /* GTK3 has no live accent setting -- static pick matching
         accent-color = "blue" below; needs a manual update if that ever
         changes. DEFAULT: theme_selected_bg #15539e. */
      @define-color theme_selected_bg_color #3584e4;
      @define-color theme_selected_fg_color #FFFFFF; /* DEFAULT */
      @define-color theme_unfocused_selected_bg_color #15539e; /* DEFAULT */
      @define-color theme_unfocused_selected_fg_color #ffffff; /* DEFAULT */
      @define-color unfocused_insensitive_color #5b5b5b; /* DEFAULT */

      /* Hairline dividers: Yaru-dark's near-black values, not Adwaita-3's
         lighter stock #1b1b1b/#202020. */
      @define-color borders #131313;
      @define-color unfocused_borders #181818;
    '';
  };

  # Per-icon override slot, deliberately empty for now -- add an entry
  # shaped like the commented examples to win over Papirus-Dark outright.
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

  # GNOME Shell theme "Custom": a from-scratch dark-mode pass over stock
  # Adwaita, split one file per UI area -- see
  # files/gnome-shell/gnome-shell.css's own header for the full rundown.
  # _generated-base.css is gnomeShellBaseCss above, not a plain source file.
  xdg.dataFile."themes/Custom/gnome-shell/_generated-base.css".source = gnomeShellBaseCss;
  xdg.dataFile."themes/Custom/gnome-shell/gnome-shell.css".source =
    ./files/gnome-shell/gnome-shell.css;
  xdg.dataFile."themes/Custom/gnome-shell/popups.css".source = ./files/gnome-shell/popups.css;
  xdg.dataFile."themes/Custom/gnome-shell/buttons.css".source = ./files/gnome-shell/buttons.css;
  xdg.dataFile."themes/Custom/gnome-shell/quick-settings.css".source =
    ./files/gnome-shell/quick-settings.css;
  xdg.dataFile."themes/Custom/gnome-shell/calendar.css".source = ./files/gnome-shell/calendar.css;
  xdg.dataFile."themes/Custom/gnome-shell/notifications.css".source =
    ./files/gnome-shell/notifications.css;
  xdg.dataFile."themes/Custom/gnome-shell/top-bar.css".source = ./files/gnome-shell/top-bar.css;
  xdg.dataFile."themes/Custom/gnome-shell/overview.css".source = ./files/gnome-shell/overview.css;
  xdg.dataFile."themes/Custom/gnome-shell/modals.css".source = ./files/gnome-shell/modals.css;

  # Tiny local extension (not from nixpkgs/extensions.gnome.org) hiding
  # the built-in "Dark Style" toggle, pointless once color-scheme is
  # pinned below. Source dir has no "@" only because Nix path literals
  # can't contain one unescaped; its real uuid (metadata.json) does.
  xdg.dataFile."gnome-shell/extensions/hide-dark-style@arby-nix/metadata.json".source =
    ./files/gnome-shell-extensions/hide-dark-style/metadata.json;
  xdg.dataFile."gnome-shell/extensions/hide-dark-style@arby-nix/extension.js".source =
    ./files/gnome-shell-extensions/hide-dark-style/extension.js;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      accent-color = "blue"; # GNOME's own default

      # User Themes has no light/dark concept of its own -- it only reacts
      # to the theme *name*, so a custom shell theme stops following the
      # system light/dark switch regardless. Pinned dark to keep
      # GTK4/libadwaita apps consistent with the shell (and makes "Dark
      # Style" pointless, hence hide-dark-style@arby-nix above).
      color-scheme = "prefer-dark";

      # Shell/Mutter reads these separately from gtk.iconTheme/cursorTheme
      # above (GTK apps only). icon-theme uses lib.mkForce over
      # default.nix's MoreWaita.
      icon-theme = lib.mkForce "PapirusPlus";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 24;
    };

    "org/gnome/desktop/wm/preferences" = {
      # Drops the small CSD titlebar app icon. Default was a stray
      # "icon:minimize,maximize,close" already in this dconf database
      # (not something this config set) -- same ordering, minus "icon:".
      button-layout = ":minimize,maximize,close";
    };

    # user-theme: lets the shell's own chrome pick up a custom theme by
    # name (vanilla GNOME Shell ignores shell themes without it). Active
    # theme is "Custom", backed by the xdg.dataFile entries above.
    # hide-dark-style: see files/gnome-shell-extensions/hide-dark-style/.
    # lib.mkForce: dconf leaf lists don't merge, so this overrides
    # default.nix's `[ "caffeine@patapon.info" ]` rather than conflicting.
    "org/gnome/shell".enabled-extensions = lib.mkForce [
      "caffeine@patapon.info"
      "user-theme@gnome-shell-extensions.gcampax.github.com"
      "hide-dark-style@arby-nix"
    ];

    "org/gnome/shell/extensions/user-theme" = {
      name = "Custom";
    };
  };
}
