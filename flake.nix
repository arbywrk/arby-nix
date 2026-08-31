{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      mkSystem = import ./lib/mksystem.nix { inherit inputs; };
      mkHome = import ./lib/mkhome.nix { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nixos-laptop-gnome = mkSystem "nixos-laptop-gnome";
        nixos-laptop-kde = mkSystem "nixos-laptop-kde";
      };

      homeConfigurations = {
        arby = mkHome { username = "arby"; };
        work = mkHome { username = "work"; };
      };
    };
}
