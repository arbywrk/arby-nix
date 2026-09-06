{ ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
  ];

  home.username = "bogdanrares";
  home.homeDirectory = "/home/bogdanrares";

  home.stateVersion = "26.05";

  xdg.enable = true;

  # Git config on this profile is managed outside this repo (work-specific
  # setup), not by home-manager.

  programs.home-manager.enable = true;
}
