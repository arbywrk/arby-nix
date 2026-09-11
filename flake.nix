{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      mkSystem = import ./lib/mksystem.nix { inherit inputs; };
      mkHome = import ./lib/mkhome.nix { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nixos = mkSystem "nixos";
      };

      homeConfigurations = {
        arby = mkHome { username = "arby"; };
        wsl = mkHome { username = "wsl"; };

        # Same content the "nixos" system applies for this user's home
        # profile, exposed standalone so `home-manager switch --flake
        # .#gnome` can iterate on it without a full nixos-rebuild.
        gnome = mkHome {
          username = "arby";
          modules = [ ./home/arby/gnome.nix ];
        };
      };
    };
}
