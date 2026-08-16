{ inputs }:
{
  username,
  system ? "x86_64-linux",
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit inputs; };
  modules = [ ../home/${username} ];
}
