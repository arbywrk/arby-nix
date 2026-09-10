{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # "Ayu" is bundled by ghostty itself (share/ghostty/themes/Ayu) --
      # this is the same Ayu Dark palette nvim (ayu-dark colorscheme) and
      # zellij (files/themes/ayu-dark.kdl) are set to, so a ghostty window
      # looks in place next to either.
      theme = "Ayu";
      font-family = "JetBrainsMono Nerd Font Mono"; # matches alacritty.nix
      font-size = 11;

      # Defaults are precision (trackpad) x1, discrete (notched mouse
      # wheel) x3 -- both dialed down here since the defaults scrolled too
      # fast. Pure personal-feel tuning, adjust freely.
      mouse-scroll-multiplier = "precision:0.6,discrete:1.5";
    };
  };
}
