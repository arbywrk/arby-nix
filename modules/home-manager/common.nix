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
}
