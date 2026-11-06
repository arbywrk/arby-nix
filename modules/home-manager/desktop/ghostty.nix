{ ... }:
{
  stylix.targets.ghostty.enable = true;

  programs.ghostty = {
    enable = true;
    settings = {
      # Stops shell integration re-adding the dir the zsh snippet below strips.
      shell-integration-features = "no-path";

      gtk-titlebar-style = "tabs";
      gtk-wide-tabs = false;
      gtk-toolbar-style = "flat";
      window-theme = "ghostty";
      window-padding-x = 0;
      window-padding-y = 0;

      mouse-scroll-multiplier = "precision:0.6,discrete:1.5"; # dialed down from defaults

      keybind = [
        # Let Ctrl+Shift+Q reach zellij's own Quit bind instead of quitting ghostty.
        "ctrl+shift+q=unbind"
        # Ctrl+Backspace / Ctrl+Shift+Backspace -> zsh's backward-kill-word
        # (^W) / backward-kill-line (^U), same as alacritty/wezterm.
        "ctrl+backspace=text:\\x17"
        "ctrl+shift+backspace=text:\\x15"
      ];
    };
  };

  # Ghostty adds its own /nix/store bin dir to every shell's PATH (not
  # controlled by "no-path"), which makes starship's nix_shell heuristic
  # always fire. ghostty itself stays on PATH via the home-manager profile.
  programs.zsh.initContent = ''
    [[ -n $GHOSTTY_BIN_DIR ]] && path=(''${path:#$GHOSTTY_BIN_DIR})
  '';
}
