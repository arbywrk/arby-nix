{ inputs }:
{
  username,
  system ? "x86_64-linux",
  # Defaults to the profile's own default.nix -- pass an explicit module
  # to expose a standalone homeConfigurations target for a profile that's
  # normally only reachable through a NixOS host (e.g. home/arby/gnome.nix).
  modules ? [ ../home/${username} ],
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ (import ../overlays) ];
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs modules;
  extraSpecialArgs = { inherit inputs; };
}
