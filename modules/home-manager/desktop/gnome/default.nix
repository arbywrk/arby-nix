# Stock-look GNOME: no shell theme, no icon/cursor swap, no libadwaita
# color overrides -- just the functional bits that make vanilla GNOME
# usable day to day (keybindings, a couple of small extensions, apps that
# replace what services.gnome.core-apps.enable = false stripped out at
# the NixOS level). See gnome/custom.nix, which imports this file and
# layers the cosmetic pass on top, and ./README.md for the split rationale.
{
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  home.packages = [
    pkgs.gnomeExtensions.caffeine

    # services.gnome.core-apps.enable = false (modules/nixos/desktop/gnome.nix)
    # drops GNOME's whole default app bundle -- these are the ones actually
    # wanted back, installed declaratively here rather than left to
    # Bazaar/Flatpak (see below) since they're core GNOME apps this repo
    # already knows how to package and keep current via nixpkgs.
    pkgs.loupe # image viewer
    pkgs.papers # document viewer (PDF/ePub/... -- GNOME's Evince rebrand)
    pkgs.gnome-calendar
    pkgs.endeavour # GNOME's own task/to-do manager
    pkgs.resources # GNOME's Rust system monitor (gnome-system-monitor's replacement)
    pkgs.seahorse # GNOME's own front-end onto the Secret Service (gnome-keyring)

    # Flathub-first app store, for anything not worth a nixpkgs entry in
    # this repo (per-user, not managed here) -- needs services.flatpak.enable
    # (modules/nixos/desktop/gnome.nix) to actually install/run flatpaks.
    pkgs.bazaar
  ];

  # Stock Adwaita ships icons for GNOME's own apps only -- third-party apps
  # (Signal, Obsidian, Brave, ...) fall back to a generic icon under it.
  # MoreWaita is Adwaita plus a large set of extra app icons drawn in the
  # same style, so it stays visually "default GNOME" while actually
  # covering what's installed here. gnome/custom.nix overrides this
  # (lib.mkForce, same pattern as enabled-extensions above) to its own
  # Papirus pick instead.
  gtk = {
    enable = true;
    iconTheme = {
      name = "MoreWaita";
      package = pkgs.morewaita-icon-theme;
    };
  };

  # Fastmail's official Flatpak, from Flathub (nix-flatpak's default remote).
  # enable is explicit -- its own default reads `osConfig`, which doesn't
  # exist for the standalone `homeConfigurations.gnome` flake target.
  services.flatpak = {
    enable = true;
    packages = [ "com.fastmail.Fastmail" ];
  };

  # User-installed Flatpaks export their .desktop files to
  # ~/.local/share/flatpak/exports/share, but systemd --user's own
  # environment (what GNOME Shell actually inherits, as opposed to a
  # login shell sourcing /etc/profile.d) never picks that path up on its
  # own -- so without this, no user Flatpak's launcher shows up in the
  # app grid, regardless of how it was installed. /var/lib/flatpak/... is
  # the equivalent for system-wide installs, added for completeness even
  # though nothing here installs at that level.
  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # GNOME Shell/Mutter (the desktop cursor and window-manager chrome,
      # as opposed to individual GTK apps) reads this separately from
      # gtk.iconTheme above, which only covers settings.ini for GTK apps
      # themselves -- both need setting for the icon theme to actually be
      # consistent everywhere. gnome/custom.nix overrides this (lib.mkForce)
      # to "PapirusPlus".
      icon-theme = "MoreWaita";
    };

    # App grid folder grouping the three office suites together (see
    # home/arby/default.nix for where libreoffice-fresh/onlyoffice come
    # from). Organizational, not cosmetic, so it's here rather than in
    # gnome/custom.nix -- useful in stock GNOME too. "System" and
    # "Utilities" in folder-children are GNOME's own stock default
    # folders (already populated, left untouched); "YaST"/"Pardus" are
    # empty leftover entries from that same untouched default and stay as
    # dead weight, same reasoning as button-layout in custom.nix.
    #
    # Collabora Office isn't in nixpkgs (checked -- Collabora only ships it
    # as a Flatpak/AppImage/deb, no nix derivation exists), so it stays a
    # Flatpak install outside this config; its desktop-file-id below is
    # Flatpak's own reverse-DNS naming, not something this repo controls.
    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "System"
        "Utilities"
        "YaST"
        "Pardus"
        "Office"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Office" = {
      name = "Office";
      apps = [
        "writer.desktop"
        "calc.desktop"
        "impress.desktop"
        "draw.desktop"
        "base.desktop"
        "math.desktop"
        "startcenter.desktop"
        "onlyoffice-desktopeditors.desktop"
        "com.collaboraoffice.Office.desktop"
      ];
    };

    "org/gnome/shell" = {
      # Caffeine: toggleable "prevent idle/suspend" -- click the mug icon in
      # the top bar, or right-click it for a timed duration. The only
      # extension stock GNOME is missing that's worth keeping regardless of
      # theme; gnome/custom.nix overrides this whole list (lib.mkForce) to
      # add its own cosmetic-support extensions on top.
      enabled-extensions = [ "caffeine@patapon.info" ];
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
