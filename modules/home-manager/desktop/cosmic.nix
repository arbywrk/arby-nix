{ ... }:
{
  # Appearance settings copied from ~/.config/cosmic after setting them in COSMIC
  # Settings. Read-only once linked: to change them, drop this entry, edit in
  # Settings, then copy the files back. force: replaces the copies Settings wrote.
  xdg.configFile."cosmic" = {
    source = ./cosmic-theme;
    recursive = true;
    force = true;
  };

  # GNOME enables IBus system-wide; its autostart only runs outside GNOME/KDE,
  # i.e. in COSMIC, where it can't attach on Wayland and pops a warning.
  xdg.configFile."autostart/ibus-daemon.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # COSMIC's built-in defaults already match the GNOME bindings in gnome.nix
  # (Super+Q close, Super+1-9 workspace, Shift+Super+1-9 move window), so
  # only the differences live here. Entries merge over the defaults; this
  # file is read-only, so COSMIC Settings can't edit the actions it sets.
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
    {
        Terminal: "ghostty",
    }
  '';

  # Super+Arrow moves focus between windows, which can jump to other workspaces.
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
    {
        (modifiers: [Super], key: "Left"): Disable,
        (modifiers: [Super], key: "Right"): Disable,
        (modifiers: [Super], key: "Up"): Disable,
        (modifiers: [Super], key: "Down"): Disable,
    }
  '';
}
