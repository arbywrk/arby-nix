{ pkgs, config, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/desktop/alacritty.nix
    ../../modules/home-manager/desktop/ghostty.nix
    ../../modules/home-manager/development/gh
    ../../modules/home-manager/development/mosh
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
    ../../modules/home-manager/development/uv
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

  programs = {
    mise.enable = true;
    brave-origin.enable = true;
    firefox.enable = true;
    home-manager.enable = true; # let it install and manage itself
  };
}
