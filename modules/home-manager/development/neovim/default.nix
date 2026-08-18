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

    # Mirrors files/lua/../init.lua: leaders set before anything else, then
    # the two non-plugin config modules. home-manager places the "advised
    # plugin config" (which sources every plugins.*.config string) at
    # lib.mkOrder 200 inside initLua; without an explicit lower mkOrder
    # here, this content gets the default priority (1000) and ends up
    # concatenated *after* that -- meaning every plugin's <leader>
    # keymaps would bind against the default "\" leader, not this one.
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

  programs.ripgrep.enable = true;

  # fzf-lua shells out to the real fzf binary for its picker UI -- it's a
  # frontend, not a pure-Lua reimplementation -- and nothing else in this
  # config was providing it.
  programs.fzf.enable = true;
}
