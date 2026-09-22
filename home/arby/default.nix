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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  xdg = {
    enable = true;
    mime.enable = true;

    # Lowercase directory names instead of xdg-user-dirs' own capitalized
    # defaults (Desktop, Documents, ...) -- purely a naming preference,
    # same well-known set of directories otherwise. This *declares*
    # user-dirs.dirs; the directories themselves were renamed on disk by
    # hand to match (this option only creates them if missing, it doesn't
    # move existing content into a newly-renamed target).
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
    pkgs.bitwarden-desktop # replaces Proton Pass (see comment below)

    # CLI apps
    pkgs.wl-clipboard
    pkgs.xclip
  ];

  # Proton Pass was never declared here -- it was only ever a browser
  # extension (installed through Brave's own extension store, which this
  # config doesn't manage), not a nixpkgs package, so there was nothing
  # to remove from this file. bitwarden-desktop above is its replacement;
  # removing the Proton Pass extension itself, and importing/exporting
  # vault data between the two, is a manual step in the browser.

  # No desktop sync client: GNOME Online Accounts (Settings > Online
  # Accounts, added interactively, not declared here) already gives
  # on-demand access to Nextcloud files through Files/Nautilus over
  # WebDAV -- nothing synced to disk, which is all that was wanted. The
  # actual sync client (services.nextcloud-client) did full bidirectional
  # local sync instead, which is more than needed, so it's gone.
  programs.git = {
    enable = true;
    settings.user = {
      name = "Rares-Andrei Bogdan";
      email = "bogdan.andrei.rares@gmail.com";
    };
  };

  # Obsidian's own packaged .desktop file (nixpkgs `obsidian`) declares no
  # StartupWMClass, and its running Electron window reports app-id
  # "md.Obsidian" (systemd names the app's cgroup scope
  # "app-md.Obsidian-<pid>.scope") -- a case/name mismatch from the plain
  # "obsidian.desktop" filename. The app grid
  # matches fine (it just reads installed .desktop files directly, no
  # window involved), but dash-to-dock has to match a *running window*
  # back to an app, fails on that mismatch, and falls back to a generic
  # icon. This entry lands at ~/.local/share/applications/obsidian.desktop,
  # which XDG's search order checks before the nix-profile-provided one of
  # the same name, so it wins outright -- same Exec/Icon/etc, just with
  # the missing StartupWMClass hint added.
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

  programs.mise.enable = true;

  programs = {
    brave-origin.enable = true;
    firefox.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
