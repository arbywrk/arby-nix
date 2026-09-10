{ inputs }:
{
  username,
  system ? "x86_64-linux",
  # Defaults to the profile's own default.nix (unchanged behavior for
  # existing callers) -- pass an explicit module (e.g. ../home/arby/gnome.nix)
  # to expose a standalone homeConfigurations target for a DE-specific
  # profile that's normally only reachable through a NixOS host.
  modules ? [ ../home/${username} ],
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs modules;
  extraSpecialArgs = { inherit inputs; };
}
