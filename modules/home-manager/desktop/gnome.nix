{ pkgs, ... }:

let
  # Only the raster "places" (folder/user-home/etc) icons from Yaru,
  # copied for real (not just Inherits-referenced) so they take priority
  # over Papirus's own folder icons below regardless of Inherits order --
  # a theme's own files always win over anything in its Inherits chain.
  # Symbolic icons deliberately excluded (share/icons/Yaru/scalable/places
  # only has *-symbolic.svg, no plain folder-symbolic base icon) so status
  # -area/tray icons that look up a symbolic "places" name still fall
  # through to Papirus, not Yaru.
  yaruwaitaIconTheme =
    let
      places-sizes = [
        "16x16"
        "16x16@2x"
        "22x22"
        "22x22@2x"
        "24x24"
        "24x24@2x"
        "32x32"
        "32x32@2x"
        "48x48"
        "48x48@2x"
        "256x256"
        "256x256@2x"
      ];
      directories = builtins.concatStringsSep "," (map (s: "${s}/places") places-sizes);
      sizeSection = s: ''
        [${s}/places]
        Size=${builtins.head (builtins.split "x" s)}
        Context=Places
        Type=Fixed
      '';
    in
    pkgs.runCommand "yaruwaita-icon-theme" { } ''
      themeDir=$out/share/icons/Yaruwaita
      mkdir -p "$themeDir"
      ${builtins.concatStringsSep "\n" (
        map (s: ''
          mkdir -p "$themeDir/${s}"
          cp -r ${pkgs.yaru-theme}/share/icons/Yaru/${s}/places "$themeDir/${s}/"
        '') places-sizes
      )}
      cat > "$themeDir/index.theme" <<EOF
      [Icon Theme]
      Name=Yaruwaita
      Comment=MoreWaita's app/mimetype coverage, Yaru's own full-color folder icons, Papirus's symbolic/status icons for everything else.
      Directories=${directories}
      Inherits=MoreWaita,Papirus-Dark,Humanity,Adwaita,AdwaitaLegacy,hicolor
      ${builtins.concatStringsSep "\n" (map sizeSection places-sizes)}
      EOF
    '';
in
{
  home.packages = [
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.dash-to-dock
    pkgs.morewaita-icon-theme
    pkgs.papirus-icon-theme
  ];

  # Yaru (Ubuntu's GTK/cursor/shell theme set) for the widget chrome, dark
  # variant, config-time only -- home-manager's gtk.* options already
  # generate the matching dconf "org/gnome/desktop/interface" keys
  # themselves (gtk-theme, icon-theme, cursor-theme, color-scheme),
  # confirmed by reading home-manager's own gtk3.nix, so those aren't
  # hand-written below. GNOME's own Appearance light/dark switch keeps
  # working normally on top of this -- nothing here fights it, it just
  # isn't driven by it either.
  #
  # Icons are "Yaruwaita" (defined above, in the `let`) -- not plain
  # MoreWaita, Yaru, or Papirus alone. Yaru's own icon set doesn't track
  # GNOME's accent-color setting (its per-accent variants like Yaru-blue/
  # Yaru-olive are static picks, not something that follows the live
  # accent-color setting -- there's no built-in link between the two, and
  # building one would mean exactly the kind of watcher this repo already
  # decided against), so pure Yaru looked out of sync. MoreWaita
  # (github.com/somepaulo/MoreWaita) fixes that (no accent identity of its
  # own, wide extra app/mimetype coverage) but -- checked directly against
  # its own icon files -- it has zero generic places icons of its own (no
  # folder.svg/user-home.svg/etc, only per-app folder variants like
  # "bitwig-project-folder"), so plain folders fell through to Adwaita's
  # own (light blue) one. And Papirus's own symbolic/status-area icons
  # (e.g. the caffeine extension's tray icon) are the ones actually wanted
  # back -- switching straight to MoreWaita lost those. So: Yaruwaita
  # copies Yaru's real full-color folder icons in directly (gray body,
  # orange/maroon gradient tab -- confirmed by opening share/icons/Yaru/
  # 256x256/places/folder.png from the built package) so they win
  # regardless of Inherits order, then falls through to
  # MoreWaita,Papirus-Dark,... for everything else -- MoreWaita for the
  # broad app/mimetype coverage, Papirus for symbolic/status icons.
  gtk = {
    enable = true;
    theme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };
    iconTheme = {
      name = "Yaruwaita";
      package = yaruwaitaIconTheme;
    };
    cursorTheme = {
      name = "Yaru"; # one cursor set covers both light and dark
      package = pkgs.yaru-theme;
      size = 24;
    };
    colorScheme = "dark";

    # Background/foreground colors only, not a full GTK4 theme import
    # (tried that -- see git history -- it did nothing, because it
    # imported Yaru's own GTK3-era variable names like `theme_bg_color`,
    # and modern libadwaita (1.9.3 here) has redefined that name as a pure
    # computed alias of `window_bg_color`, not an independently settable
    # value; extracted libadwaita's actual shipped stylesheet straight out
    # of libadwaita-1.so.0 to confirm the real variable names below, and
    # Yaru's own intended values straight out of its GTK4 gresource
    # (theme_bg_color #2c2c2c, theme_base_color #272727). Only the
    # background/foreground colors Yaru actually specifies are set;
    # everything else (sidebar/card/popover/dialog colors, which Yaru's
    # own GTK3-era variable set never defined in the first place) is left
    # alone to fall back to libadwaita's own dark defaults, deliberately
    # not inventing values Yaru itself doesn't have an opinion on.
    # Deliberately NOT touching accent_bg_color/accent_fg_color here --
    # accent stays whatever "org/gnome/desktop/interface accent-color"
    # below is set to (blue), not Yaru's orange; this is the one color
    # explicitly meant to stay native/unmatched. Wrapped in the same
    # `@media (prefers-color-scheme: dark)` guard libadwaita's own
    # dark-mode block uses, so it won't leak into light mode if that's
    # ever turned on. GTK4 apps' header-bar shape/button layout still
    # can't be touched this way -- that part really is a hard libadwaita
    # limit, no CSS variable reaches it (more on that below).
    gtk4.extraCss = ''
      @media (prefers-color-scheme: dark) {
        @define-color window_bg_color #2c2c2c;
        @define-color window_fg_color #F7F7F7;
        @define-color view_bg_color #272727;
        @define-color view_fg_color #F7F7F7;
        @define-color headerbar_bg_color #2c2c2c;
        @define-color headerbar_fg_color #F7F7F7;
      }
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      accent-color = "blue"; # GNOME's own default
    };

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
