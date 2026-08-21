{ inputs, ... }:
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  # Installed via Flatpak instead of the nixpkgs package on desktop
  # systems. Explicit `enable` here (rather than relying on nix-flatpak's
  # own osConfig-derived default) so this also evaluates cleanly when this
  # home is built standalone (`homeConfigurations.arby`, no real NixOS
  # `osConfig` behind it) -- the underlying system flatpak service/portal
  # itself is still enabled at the NixOS level, see
  # modules/nixos/desktop/gnome.nix.
  #
  # Note: the previous nixpkgs-package setup carried a window_decorations
  # workaround for a GNOME/Mutter decoration bug (see git history on this
  # file) -- that was wired through home-manager's programs.wezterm module,
  # which only writes config for the nixpkgs-built binary. The Flatpak
  # build may or may not read the same ~/.config/wezterm/wezterm.lua
  # depending on its sandbox permissions; re-add that workaround here if
  # the same issue shows up.
  services.flatpak = {
    enable = true;
    packages = [ "org.wezfurlong.wezterm" ];
  };
}
