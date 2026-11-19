# Shared by Zen and LibreWolf.
let
  # Extension id -> addons.mozilla.org slug.
  extensions = {
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
    "ente-auth-extension@adamheimowitz.com" = "duckey"; # Ente Auth autofill
  };
in
{
  # Installed from addons.mozilla.org on launch, kept up to date by the browser.
  ExtensionSettings = builtins.mapAttrs (_: slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "force_installed";
    # Pinned to the toolbar instead of hidden in the extensions menu.
    default_area = "navbar";
  }) extensions;

  # Bitwarden handles passwords instead.
  PasswordManagerEnabled = false;
  OfferToSaveLogins = false;
}
