{ ... }:
{
  # Same Ayu Dark palette as ghostty.nix / nvim's ayu-dark colorscheme /
  # zellij's ayu-dark.kdl -- values pulled straight from ghostty's own
  # bundled Ayu theme file, not retyped from memory, so all four agree
  # exactly.
  programs.gnome-terminal = {
    enable = true;
    themeVariant = "dark";
    profile."3f9c2b7e-2f4a-4f1b-9b3d-7a1c0e5d6f21" = {
      default = true;
      visibleName = "Ayu";
      colors = {
        foregroundColor = "#bfbdb6";
        backgroundColor = "#0b0e14";
        palette = [
          "#11151c"
          "#ea6c73"
          "#7fd962"
          "#f9af4f"
          "#53bdfa"
          "#cda1fa"
          "#90e1c6"
          "#c7c7c7"
          "#686868"
          "#f07178"
          "#aad94c"
          "#ffb454"
          "#59c2ff"
          "#d2a6ff"
          "#95e6cb"
          "#ffffff"
        ];
        cursor = {
          foreground = "#0b0e14";
          background = "#e6b450";
        };
        highlight = {
          foreground = "#0b0e14";
          background = "#409fff";
        };
      };
      font = "JetBrainsMono Nerd Font Mono 11";
    };
  };
}
