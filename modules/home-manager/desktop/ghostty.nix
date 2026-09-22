{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Static, not "light:Ayu Light,dark:Ayu Dark Gray" -- zellij's own
      # theme is always static dark, so following GNOME's light/dark
      # switch here would produce a seam whenever ghostty goes light with
      # zellij running.
      theme = "Ayu Dark Gray";
      font-family = "JetBrainsMono Nerd Font Mono"; # matches alacritty.nix
      font-size = 11;

      mouse-scroll-multiplier = "precision:0.6,discrete:1.5"; # dialed down from defaults

      # Ctrl+Shift+Q quits the whole app by default -- unbind so the
      # keypress passes through to zellij's own Quit action on the same
      # chord instead (development/zellij/default.nix).
      keybind = [ "ctrl+shift+q=unbind" ];
    };

    # Ayu Dark's bundled palette, with background/cursor-text/selection
    # swapped for near-black/gray instead of Ayu's stock blue-tinted
    # values -- same substitutions as zellij's ayu-dark.kdl, so both blend
    # consistently. ANSI blue (4/12) is left alone; that's semantic.
    themes."Ayu Dark Gray" = {
      palette = [
        "0=#11151c"
        "1=#ea6c73"
        "2=#7fd962"
        "3=#f9af4f"
        "4=#53bdfa"
        "5=#cda1fa"
        "6=#90e1c6"
        "7=#c7c7c7"
        "8=#686868"
        "9=#f07178"
        "10=#aad94c"
        "11=#ffb454"
        "12=#59c2ff"
        "13=#d2a6ff"
        "14=#95e6cb"
        "15=#ffffff"
      ];
      background = "131313";
      foreground = "bfbdb6";
      cursor-color = "e6b450";
      cursor-text = "131313";
      selection-background = "3c3c3c";
      selection-foreground = "bfbdb6";
    };
  };
}
