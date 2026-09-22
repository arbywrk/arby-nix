{ pkgs, ... }:

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
  };

  home.packages = [
    # GUI apps
    pkgs.signal-desktop
    pkgs.localsend
    pkgs.obsidian
    pkgs.libreoffice-fresh
    pkgs.sioyek
    pkgs.onlyoffice-desktopeditors

    # CLI apps
    pkgs.wl-clipboard
    pkgs.xclip
    pkgs.proton-drive-cli
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

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
