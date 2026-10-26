{ ... }:
{
  stylix.targets.alacritty = {
    enable = true;
    opacity.enable = false; # translucent here only, set below
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.80;

      # Ctrl+Backspace / Ctrl+Shift+Backspace -> zsh's stock backward-kill-word
      # (^W) / backward-kill-line (^U) bytes. builtins.fromJSON produces the
      # real control byte -- Nix has no \u escape of its own.
      keyboard.bindings = [
        {
          key = "Backspace";
          mods = "Control";
          chars = builtins.fromJSON ''"\u0017"'';
        }
        {
          key = "Backspace";
          mods = "Control|Shift";
          chars = builtins.fromJSON ''"\u0015"'';
        }
      ];
    };
  };
}
