{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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

        # Same content nixos-laptop-gnome applies for this user's home
        # profile, exposed standalone so `home-manager switch --flake
        # .#arby-gnome` can iterate on it without a full nixos-rebuild.
        arby-gnome = mkHome {
          username = "arby";
          modules = [ ./home/arby/gnome.nix ];
        };
      };
    };
}
