{
  pkgs,
  lib,
  config,
  ...
}:
{
  fonts.fontconfig = {
    enable = true;
    # "Mono" variant specifically: fixed advance width for icon glyphs
    # too, so terminal grid alignment stays correct.
    defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
  };

  # `programs.home-manager.enable` (set per home/*/default.nix) only adds
  # the CLI package when `!submoduleSupport.enable` -- which NixOS
  # integration sets to true, since nixos-rebuild drives that instance
  # instead. Add the package back explicitly in that case so `home-manager
  # switch --flake .#gnome` still works for quick iteration without a
  # full nixos-rebuild; the standalone homeConfigurations targets already
  # get it for free and would double up if this applied unconditionally.
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ]
  ++ lib.optional config.submoduleSupport.enable pkgs.home-manager;

  programs.bat.enable = true;
  home.shellAliases.cat = "bat";

  # lsd's own zsh integration already provides ls/ll/la/lt/lla/llt.
  programs.lsd.enable = true;
}
