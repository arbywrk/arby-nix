{ ... }:
{
  # COSMIC's built-in defaults already match the GNOME bindings in gnome.nix
  # (Super+Q close, Super+1-9 workspace, Shift+Super+1-9 move window), so
  # only the differences live here. Entries merge over the defaults; this
  # file is read-only, so COSMIC Settings can't edit the actions it sets.
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
    {
        Terminal: "ghostty",
    }
  '';
}
