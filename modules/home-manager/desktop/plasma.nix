{ inputs, lib, ... }:
let
  desktops = lib.range 1 9;
  forDesktops = f: lib.listToAttrs (map f desktops);
in
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma = {
    enable = true;

    kwin.virtualDesktops = {
      number = 9;
      rows = 1;
    };

    # Same bindings as GNOME and COSMIC.
    shortcuts = {
      kwin = {
        "Window Close" = [
          "Alt+F4"
          "Meta+Q"
        ];
      }
      // forDesktops (n: lib.nameValuePair "Switch to Desktop ${toString n}" "Meta+${toString n}")
      # KDE may record Shift+digit as the shifted symbol, so bind both forms.
      // forDesktops (
        n:
        lib.nameValuePair "Window to Desktop ${toString n}" [
          "Meta+Shift+${toString n}"
          "Meta+${builtins.elemAt (lib.stringToCharacters "!@#$%^&*(") (n - 1)}"
        ]
      );

      # Frees Meta+1..9 from the task manager.
      plasmashell = forDesktops (n: lib.nameValuePair "activate task manager entry ${toString n}" [ ]);
    };

    configFile.kdeglobals.General.TerminalApplication = "ghostty";
  };
}
