# Packages not (yet) in nixpkgs. Applied to both nixosSystem (via
# nixpkgs.overlays in lib/mksystem.nix) and standalone Home Manager (via
# the `overlays` argument to `import inputs.nixpkgs { ... }` in
# lib/mkhome.nix) so `pkgs.<name>` resolves the same way everywhere.
final: prev: {
  proton-drive-cli = final.callPackage ../pkgs/proton-drive-cli { };
}
