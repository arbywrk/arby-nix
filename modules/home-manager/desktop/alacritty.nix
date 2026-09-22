{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "JetBrainsMono Nerd Font Mono";
        bold.family = "JetBrainsMono Nerd Font Mono";
        italic.family = "JetBrainsMono Nerd Font Mono";
        size = 11;
      };

      window.opacity = 0.80;

      # Same palette as neovim's colorscheme and zellij's theme, so
      # nvim/zellij/alacritty all agree.
      colors = {
        primary = {
          background = "#141415";
          foreground = "#cdcdcd";
        };
        cursor = {
          text = "#141415";
          cursor = "#cdcdcd";
        };
        selection = {
          text = "#cdcdcd";
          background = "#333738";
        };
        normal = {
          black = "#252530";
          red = "#d8647e";
          green = "#7fa563";
          yellow = "#f3be7c";
          blue = "#6e94b2";
          magenta = "#bb9dbd";
          cyan = "#aeaed1";
          white = "#cdcdcd";
        };
        bright = {
          black = "#606079";
          red = "#e08398";
          green = "#99b782";
          yellow = "#f5cb96";
          blue = "#8ba9c1";
          magenta = "#c9b1ca";
          cyan = "#bebeda";
          white = "#d7d7d7";
        };
      };

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
