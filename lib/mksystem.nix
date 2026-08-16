{ inputs }:
hostname:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../hosts/${hostname}
    ../modules/nixos/common.nix
    inputs.home-manager.nixosModules.default
  ];
}
