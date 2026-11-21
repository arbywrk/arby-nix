{ ... }:
{
  # Appearance as saved by COSMIC Settings. Read-only once linked.
  xdg.configFile."cosmic" = {
    source = ./cosmic-theme;
    recursive = true;
    force = true;
  };

  # GNOME's IBus autostart also runs here, where it only shows a Wayland warning.
  xdg.configFile."autostart/ibus-daemon.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # Merged over COSMIC's defaults, which already match the GNOME bindings.
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
    {
        Terminal: "ghostty",
    }
  '';

  # Super+Arrow focus jumps across workspaces.
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
    {
        (modifiers: [Super], key: "Left"): Disable,
        (modifiers: [Super], key: "Right"): Disable,
        (modifiers: [Super], key: "Up"): Disable,
        (modifiers: [Super], key: "Down"): Disable,
    }
  '';

  # Ctrl+Shift+Q closes the window; zellij needs it.
  xdg.configFile."cosmic/com.system76.CosmicTerm/v1/shortcuts_custom".text = ''
    ({
        (modifiers: [Ctrl, Shift], key: "Q"): Disable,
    })
  '';
}
