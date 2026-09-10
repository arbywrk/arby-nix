{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Light half is ghostty's own bundled "Ayu Light" theme, unmodified.
      # Dark half is the custom "Ayu Dark Gray" theme below, not the
      # bundled "Ayu" -- ghostty can natively follow GNOME's light/dark
      # switch (this light:/dark: syntax is what makes it do that; a plain
      # `theme = "Ayu"` is static and ignores the desktop setting entirely,
      # which is why it wasn't following it before), so this is what picks
      # that up automatically.
      theme = "light:Ayu Light,dark:Ayu Dark Gray";
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
    # background/cursor-text swap Ayu's stock blue-black (#0b0e14) for
    # Yaru-dark's actual shell panel color -- #131313, read straight out
    # of Yaru's own gnome-shell.css (`#panel { background-color: #131313;
    # }`), not guessed -- and selection-background swaps Ayu's sky-blue
    # (#409fff) for a plain mid gray (#3c3c3c) -- same substitutions
    # zellij's ayu-dark.kdl makes, for the same reason (blend with Yaru's
    # actual near-black instead of Ayu's blue undertone). ANSI palette
    # colors 4 and 12 are still literally blue -- untouched, since those
    # are semantic (shell tools color actual "blue" output with them), not
    # background decoration.
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
