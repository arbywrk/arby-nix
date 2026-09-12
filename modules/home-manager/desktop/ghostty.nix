{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Static, not "light:Ayu Light,dark:Ayu Dark Gray" -- ghostty can
      # natively follow GNOME's light/dark switch via that syntax, but
      # zellij's own theme is always static ayu-dark (its color model has
      # no transparency, so its tab-bar/status-bar can't blend into a
      # light background), which produces a stark seam whenever ghostty
      # goes light with zellij running. Pinned dark to match zellij
      # exactly, at the cost of never following the system light/dark
      # toggle.
      theme = "Ayu Dark Gray";
      font-family = "JetBrainsMono Nerd Font Mono"; # matches alacritty.nix
      font-size = 11;

      # Defaults are precision (trackpad) x1, discrete (notched mouse
      # wheel) x3 -- both dialed down here since the defaults scrolled too
      # fast. Pure personal-feel tuning, adjust freely.
      mouse-scroll-multiplier = "precision:0.6,discrete:1.5";

      # Ctrl+Shift+Q quits the whole app by default (`quit`, not just
      # closing the current window/tab) -- "unbind" removes ghostty's own
      # binding so the raw keypress passes through to whatever's running
      # in the terminal instead, which is exactly what's wanted here:
      # zellij binds the same chord to its own Quit action (see
      # development/zellij/default.nix's `shared_except "locked" { bind
      # "Ctrl Shift q" { Quit; } }`), and this lets it actually reach
      # zellij instead of ghostty eating it first.
      keybind = [ "ctrl+shift+q=unbind" ];
    };

    # Ayu Dark's own palette (ghostty's bundled "Ayu" theme file), except
    # background/cursor-text use Yaru-dark's actual shell panel color
    # (#131313) instead of Ayu's stock blue-black (#0b0e14), and
    # selection-background uses a plain mid gray (#3c3c3c) instead of
    # Ayu's sky-blue (#409fff) -- same substitutions zellij's
    # ayu-dark.kdl makes, so both blend with Yaru's near-black rather
    # than carrying Ayu's blue undertone. ANSI palette colors 4 and 12
    # stay literally blue -- those are semantic (shell tools color actual
    # "blue" output with them), not background decoration.
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
