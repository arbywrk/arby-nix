# Two Neovims sharing core/: coding/ is the default `nvim`, writing/ is
# `nvim-writing` (alias `nw`) for Typst. Profiles depend on core only, never
# on each other. This file holds the environment both rely on.
{ pkgs, ... }:
{
  imports = [
    ./coding
    ./writing
  ];

  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # nixpkgs' neovim/vim packages ship .desktop launchers meant to be run
  # from a terminal, but they still show up in GNOME's app grid. Shadow
  # both IDs under ~/.local/share/applications (which wins over the
  # nix-profile copy) with noDisplay to drop them from app-grid/search
  # without touching the actual packages/aliases.
  xdg.desktopEntries = {
    nvim = {
      name = "Neovim wrapper";
      exec = "nvim %F";
      terminal = true;
      noDisplay = true;
    };
    vim = {
      name = "Vim";
      exec = "vim %F";
      terminal = true;
      noDisplay = true;
    };
  };

  programs.ripgrep.enable = true;
  # fzf-lua's files picker prefers fd when it's on PATH.
  programs.fd.enable = true;

  # fzf-lua is a frontend to the real fzf binary.
  programs.fzf.enable = true;
  stylix.targets.fzf.enable = true;
}
