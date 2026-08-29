{ inputs, ... }:

{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma = {
    enable = true;

    workspace = {
      # Global Theme "Breeze Dark" -- cascades color scheme, plasma style,
      # and window decoration together, so dark mode is consistent instead
      # of just flipping the color scheme on top of a light-tuned theme.
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    # A single top panel (macOS-menu-bar style) instead of the default
    # bottom taskbar -- same default widget set, just relocated and
    # slimmed down. Note: this replaces the panel, it doesn't add a
    # separate dock -- say the word if you also want a bottom dock to
    # complete the macOS look.
    panels = [
      {
        location = "top";
        height = 32;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # Mirrors the Super+1..9 workspace remap in
    # modules/home-manager/desktop/gnome.nix, so the muscle memory carries
    # over between sessions.
    shortcuts.kwin = {
      "Switch to Desktop 1" = "Meta+1";
      "Switch to Desktop 2" = "Meta+2";
      "Switch to Desktop 3" = "Meta+3";
      "Switch to Desktop 4" = "Meta+4";
      "Switch to Desktop 5" = "Meta+5";
      "Switch to Desktop 6" = "Meta+6";
      "Switch to Desktop 7" = "Meta+7";
      "Switch to Desktop 8" = "Meta+8";
      "Switch to Desktop 9" = "Meta+9";

      "Window to Desktop 1" = "Meta+Shift+1";
      "Window to Desktop 2" = "Meta+Shift+2";
      "Window to Desktop 3" = "Meta+Shift+3";
      "Window to Desktop 4" = "Meta+Shift+4";
      "Window to Desktop 5" = "Meta+Shift+5";
      "Window to Desktop 6" = "Meta+Shift+6";
      "Window to Desktop 7" = "Meta+Shift+7";
      "Window to Desktop 8" = "Meta+Shift+8";
      "Window to Desktop 9" = "Meta+Shift+9";
    };
  };

  # kdesystemsettings.desktop ships NotShowIn=KDE upstream (a "show in
  # every non-KDE DE" fallback tile) -- that's exactly the leak into GNOME
  # we don't want, since systemsettings.desktop itself is already
  # OnlyShowIn=KDE and covers Plasma correctly on its own. Shadow it fully
  # hidden; user data dirs win over system ones in XDG_DATA_DIRS, so no
  # NixOS-level package surgery is needed for this one.
  xdg.desktopEntries."kdesystemsettings" = {
    name = "KDE System Settings";
    exec = "systemsettings";
    icon = "preferences-system";
    noDisplay = true;
  };

  # Natural scrolling for this laptop's touchpad (device identity confirmed
  # against /proc/bus/input/devices -- hardware-specific to this machine,
  # same as the LUKS UUID in hosts/nixos-laptop/default.nix).
  programs.plasma.input.touchpads = [
    {
      name = "ELAN0689:00 04F3:320C Touchpad";
      vendorId = "04f3";
      productId = "320c";
      naturalScroll = true;
    }
  ];
}
