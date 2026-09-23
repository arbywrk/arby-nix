# Stock-look GNOME: functional bits only (keybindings, extensions, apps
# replacing what services.gnome.core-apps.enable = false stripped out).
# See ./custom.nix (imports this, layers cosmetics on top) and
# ./README.md for the split rationale.
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

    # Apps to bring back after core-apps.enable = false
    # (modules/nixos/desktop/gnome.nix), packaged via nixpkgs rather than
    # left to Bazaar/Flatpak since nixpkgs already tracks them fine.
    pkgs.loupe # image viewer
    pkgs.papers # document viewer (PDF/ePub/... -- GNOME's Evince rebrand)
    pkgs.gnome-calendar
    pkgs.endeavour # GNOME's own task/to-do manager
    pkgs.resources # GNOME's Rust system monitor (gnome-system-monitor's replacement)
    pkgs.seahorse # GNOME's own front-end onto the Secret Service (gnome-keyring)

    # Flathub-first app store for anything not worth a nixpkgs entry here
    # -- needs services.flatpak.enable (modules/nixos/desktop/gnome.nix).
    pkgs.bazaar
  ];

  # Stock Adwaita only ships icons for GNOME's own apps -- MoreWaita adds
  # coverage for third-party apps while staying visually "default GNOME".
  # custom.nix overrides this (lib.mkForce) to Papirus instead.
  gtk = {
    enable = true;
    iconTheme = {
      name = "MoreWaita";
      package = pkgs.morewaita-icon-theme;
    };
  };

  # Official Flatpaks, from Flathub (nix-flatpak's default remote). enable
  # is explicit -- its own default reads `osConfig`, which doesn't exist
  # for the standalone `homeConfigurations.gnome` flake target.
  services.flatpak = {
    enable = true;
    packages = [
      "com.fastmail.Fastmail"
      "io.ente.auth" # Ente Auth (2FA/TOTP)
    ];
  };

  # User Flatpaks export .desktop files to
  # ~/.local/share/flatpak/exports/share, but that's not on GNOME Shell's
  # XDG_DATA_DIRS by default -- without this, no Flatpak launcher shows
  # up in the app grid. /var/lib/flatpak/... is the system-install
  # equivalent, added for completeness though unused here.
  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # GNOME Shell/Mutter (the desktop cursor and window-manager chrome,
      # Shell/Mutter reads its own icon-theme key separately from
      # gtk.iconTheme above (GTK apps only) -- both need setting.
      # custom.nix overrides this (lib.mkForce) to "PapirusPlus".
      icon-theme = "MoreWaita";
    };

    # App-grid folder grouping the office suites. "YaST"/"Pardus" are
    # empty stock-default leftovers, left as-is. Collabora Office isn't
    # in nixpkgs (Flatpak/AppImage/deb only), hence its Flatpak-style
    # desktop-file-id below.
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
      # custom.nix overrides this whole list (lib.mkForce) to add its own
      # cosmetic-support extensions on top.
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
