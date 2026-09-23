{ ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/development/mosh.nix
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
  ];

  home.username = "bogdanrares";
  home.homeDirectory = "/home/bogdanrares";

  home.stateVersion = "26.05";

  xdg.enable = true;

  programs.home-manager.enable = true;
}
