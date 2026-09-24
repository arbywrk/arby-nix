{ pkgs, config, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/desktop/alacritty.nix
    ../../modules/home-manager/desktop/ghostty.nix
    ../../modules/home-manager/desktop/gnome.nix
    ../../modules/home-manager/development/gh.nix
    ../../modules/home-manager/development/mosh.nix
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
    ../../modules/home-manager/development/uv.nix
  ];

  home.username = "arby";
  home.homeDirectory = "/home/arby";

  # Compat marker for Home Manager's on-disk state format -- don't bump
  # without reading the release notes, regardless of the actual HM version.
  home.stateVersion = "26.05";

  xdg = {
    enable = true;
    mime.enable = true;

    # Lowercase dir names instead of xdg-user-dirs' capitalized defaults.
    # Only declares user-dirs.dirs -- the directories were renamed on disk
    # by hand to match.
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      projects = "${config.home.homeDirectory}/projects";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
    };
  };

  home.packages = [
    # GUI apps
    pkgs.signal-desktop
    pkgs.localsend
    pkgs.obsidian
    pkgs.libreoffice-fresh
    pkgs.sioyek
    pkgs.onlyoffice-desktopeditors
    pkgs.bitwarden-desktop # replaces Proton Pass, which was browser-extension-only

    # CLI apps
    pkgs.wl-clipboard
    pkgs.xclip
  ];

  # No desktop sync client: GNOME Online Accounts (Settings > Online
  # Accounts, added interactively) gives on-demand Nextcloud access over
  # WebDAV, which is all that's wanted -- services.nextcloud-client did
  # full local sync instead, more than needed.
  programs.git = {
    enable = true;
    settings.user = {
      name = "Rares-Andrei Bogdan";
      email = "contact@arbywrk.com";
    };
  };

  # nixpkgs' obsidian.desktop declares no StartupWMClass, but its window
  # reports app-id "md.Obsidian" -- add the hint so window-matching (task
  # switchers, dock-style extensions) can find it by class. Same
  # Exec/Icon/etc as the original; this just overrides it via XDG's search
  # order (~/.local/share/applications wins over the nix-profile copy).
  # Option docs: https://home-manager-options.extranix.com/?query=xdg.desktopEntries
  xdg.desktopEntries.obsidian = {
    name = "Obsidian";
    comment = "Knowledge base";
    exec = "obsidian %u";
    icon = "obsidian";
    categories = [ "Office" ];
    mimeType = [ "x-scheme-handler/obsidian" ];
    settings = {
      Version = "1.5";
      StartupWMClass = "md.Obsidian";
    };
  };

  # nixpkgs' localsend package ships one desktop file, id "LocalSend"
  # (StartupWMClass=localsend_app), but the real running window reports the
  # Wayland app-id "org.localsend.localsend_app" (confirmed via `strings` on
  # the binary -- it's LocalSend's actual Flathub app ID). GNOME Shell's
  # window-to-launcher matching prefers an exact desktop-file-ID match over
  # StartupWMClass, so neither of nixpkgs' identifiers match what the window
  # reports and the dash falls back to a generic icon (the app grid doesn't
  # care -- it just reads whichever .desktop file, no window involved). Fix:
  # add an entry whose ID *is* the real app-id (same trick Flatpak apps get
  # for free, e.g. com.fastmail.Fastmail below) and hide nixpkgs' mismatched
  # one so there's no duplicate app-grid entry.
  xdg.desktopEntries."LocalSend" = {
    name = "LocalSend";
    noDisplay = true;
  };
  xdg.desktopEntries."org.localsend.localsend_app" = {
    name = "LocalSend";
    genericName = "File Transfer";
    comment = "Open source cross-platform alternative to AirDrop";
    exec = "localsend_app %U";
    icon = "localsend";
    categories = [
      "GTK"
      "FileTransfer"
      "Network"
      "Utility"
    ];
    settings = {
      Version = "1.5";
      Keywords = "Sharing;LAN;Files";
      StartupNotify = "true";
      StartupWMClass = "org.localsend.localsend_app";
    };
  };

  programs = {
    mise.enable = true;
    brave-origin.enable = true;
    firefox.enable = true;
    home-manager.enable = true; # let it install and manage itself
  };
}
