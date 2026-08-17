{ pkgs, ... }:
{
  fonts.fontconfig = {
    enable = true;
    # "Mono" variant specifically: fixed advance width for the icon
    # glyphs too, so terminal grid alignment stays correct (the
    # proportional "Nerd Font" variant can misalign icon columns).
    defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
  };

  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  programs.bat.enable = true;
  home.shellAliases.cat = "bat";

  # ls/ll/la/lt/lla/llt aliases come free via its own zsh integration --
  # no need for a manual home.shellAliases.ls (would conflict with it).
  programs.lsd.enable = true;
}
