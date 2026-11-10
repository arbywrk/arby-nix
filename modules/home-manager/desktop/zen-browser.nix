{ inputs, lib, ... }:
let
  # Extension id -> addons.mozilla.org slug.
  extensions = {
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
    "ente-auth-extension@adamheimowitz.com" = "duckey"; # Ente Auth autofill
  };
in
{
  # beta = Zen's stable release channel.
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;

    policies = {
      # Installed from addons.mozilla.org on launch, kept up to date by Zen.
      ExtensionSettings = builtins.mapAttrs (_: slug: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        installation_mode = "force_installed";
      }) extensions;

      # Bitwarden handles passwords instead.
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
    };

    profiles.default = {
      # On the toolbar instead of hidden in the extensions menu. Placed on
      # switch only if Zen is closed and has been launched at least once.
      extensionButtons.nav-bar = lib.attrNames extensions;

      # Pins are written into Zen's session file on switch: close Zen first.
      # ids are arbitrary UUIDs but must stay fixed: Zen tracks pins by them.
      # isEssential: shown as icons at the top, in every space.
      pins = {
        "YouTube Music" = {
          id = "c9803b7c-72ac-4b19-82a4-04b390c2cca2";
          url = "https://music.youtube.com";
          position = 100;
          isEssential = true;
        };
        "Microsoft Teams" = {
          id = "313a4134-04c7-4138-a911-7d123a1a6345";
          url = "https://teams.microsoft.com";
          position = 200;
          isEssential = true;
        };
      };
    };
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "default" ];
  };
}
