{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;

  key = mods: key: action: { inherit mods key action; };
  unbind = mods: k: key mods k (mkLuaInline "wezterm.action.DisableDefaultAssignment");
  # Raw Lua literal: toLua would emit "\u0017", which Lua rejects (needs \x17).
  sendBytes =
    mods: k: bytes:
    key mods k { SendString = mkLuaInline ''"${bytes}"''; };
in
{
  stylix.targets.wezterm.enable = true;

  programs.wezterm = {
    enable = true;
    settings = {
      # Tabs are zellij's job; hide the bar and drop the binds below.
      enable_tab_bar = false;
      window_padding = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };

      keys = [
        # Ctrl+Backspace / Ctrl+Shift+Backspace -> zsh's backward-kill-word
        # (^W) / backward-kill-line (^U), same as alacritty.
        (sendBytes "CTRL" "Backspace" "\\x17")
        (sendBytes "CTRL|SHIFT" "Backspace" "\\x15")

        # Let zellij's Ctrl+Shift+K/L MovePane binds through.
        (unbind "CTRL|SHIFT" "k")
        (unbind "CTRL|SHIFT" "l")

        # No tabs: free the spawn/switch/move-tab defaults for apps.
        (unbind "CTRL|SHIFT" "t")
        (unbind "SUPER" "t")
        (unbind "CTRL" "Tab")
        (unbind "CTRL|SHIFT" "Tab")
        (unbind "CTRL" "PageUp")
        (unbind "CTRL" "PageDown")
        (unbind "CTRL|SHIFT" "PageUp")
        (unbind "CTRL|SHIFT" "PageDown")
      ]
      ++ map (n: unbind "CTRL|SHIFT" (toString n)) (lib.range 1 9);
    };
  };
}
