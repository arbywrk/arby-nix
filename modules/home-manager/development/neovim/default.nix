# Neovim config: plugins.nix wires nixpkgs.vimPlugins together, self-lua.nix
# puts the raw files/lua modules (options, keymaps, config/**) on the
# runtimepath, packages.nix/debug-packages.nix bring in LSP servers,
# formatters, linters, and debug adapters.
{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = import ./plugins.nix { inherit pkgs; } ++ [
      (import ./self-lua.nix { inherit pkgs; })
    ];

    # mkOrder 100: home-manager concatenates plugin config at mkOrder 200,
    # so this has to land before it -- otherwise plugins' <leader> keymaps
    # would bind against the default "\" leader instead of this one.
    initLua = lib.mkOrder 100 ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      vim.g.have_nerd_font = true

      require("options")
      require("keymaps")
    '';
  };

  home.packages =
    (import ./packages.nix { inherit pkgs; })
    ++ (import ./debug-packages.nix { inherit pkgs; })
    ++ [ pkgs.nerd-fonts.jetbrains-mono ];

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

  # fzf-lua shells out to the real fzf binary for its picker UI -- it's a
  # frontend, not a pure-Lua reimplementation -- and nothing else in this
  # config was providing it.
  programs.fzf.enable = true;
}
