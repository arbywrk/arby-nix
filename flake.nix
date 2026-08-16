{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      mkSystem = import ./lib/mksystem.nix { inherit inputs; };
    in
    {
      nixosConfigurations.thinkpad-p16s-nixos = mkSystem "thinkpad-p16s-nixos";
    };
}
