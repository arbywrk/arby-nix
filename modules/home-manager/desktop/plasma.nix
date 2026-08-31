{ pkgs, inputs, ... }:

{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  # Papirus (dark variant, to match the Breeze Dark global theme below) --
  # setting workspace.iconTheme only points Plasma at the theme name, it
  # doesn't install it, so the package has to come along too.
  home.packages = [ pkgs.papirus-icon-theme ];

  programs.plasma = {
    enable = true;

    workspace = {
      # Global Theme "Breeze Dark" -- cascades color scheme, plasma style,
      # and window decoration together, so dark mode is consistent instead
      # of just flipping the color scheme on top of a light-tuned theme.
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
    };

    kwin.virtualDesktops.number = 4;

    # Two panels for the macOS-inspired layout: a slim top menu bar, and a
    # floating, centered, auto-hiding icon dock along the bottom -- Plasma's
    # own panel system, not Latte Dock (dead on Plasma 6/Wayland; its
    # maintained successors aren't packaged in nixpkgs, so they'd mean an
    # unofficial third-party flake input rather than the current standard
    # way Plasma users get a dock look).
    panels = [
      {
        location = "top";
        height = 32;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
      {
        location = "bottom";
        floating = true;
        alignment = "center";
        hiding = "dodgewindows";
        height = 56;
        widgets = [ "org.kde.plasma.icontasks" ];
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
