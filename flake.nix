{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Not in nixpkgs; this community flake is the usual source.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # TEMPORARY: last nixpkgs with brave-origin (removed 2026-11-03). Gets no
    # security updates -- drop once fully moved to Zen.
    nixpkgs-brave.url = "github:nixos/nixpkgs/1d060086d60cb76a40cf37109f979d88a5bd6396";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Only used to pin nixd's flake-parts option completion (see neovim module).
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
        okami = mkSystem "okami";
      };

      homeConfigurations = {
        arby = mkHome { username = "arby"; };
        wsl = mkHome { username = "wsl"; };
      };
    };
}
