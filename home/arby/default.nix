{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/desktop/gnome.nix
    ../../modules/home-manager/desktop/alacritty.nix
    ../../modules/home-manager/development/gh
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
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

  programs.git = {
    enable = true;
    settings.user = {
      name = "Rares-Andrei Bogdan";
      email = "bogdan.andrei.rares@gmail.com";
    };
  };

  programs.mise.enable = true;

  programs.brave-origin.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
