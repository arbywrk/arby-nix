{ inputs }:
{
  username,
  system ? "x86_64-linux",
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ (import ../overlays) ];
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [ ../home/${username} ];
  extraSpecialArgs = { inherit inputs; };
}
