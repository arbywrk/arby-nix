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

  # nixpkgs' neovim package ships its own "Neovim wrapper" launcher
  # (share/applications/nvim.desktop) that shows up in GNOME's app grid --
  # it's meant to be run from a terminal, not launched as a GUI app.
  # Shadowing the same desktop-entry ID under ~/.local/share/applications
  # (which home-manager's xdg.desktopEntries writes to, and which takes
  # priority over the nixpkgs-provided copy) with noDisplay lets the
  # package/binary/vi-vim aliases stay exactly as they are, it just drops
  # out of app-grid/search listings.
  #
  # A plain "Vim" entry also shows up even though `pkgs.vim` isn't declared
  # anywhere in this repo (grepped to confirm) -- it's pulled in
  # transitively by something else's build/runtime closure. Same shadow
  # treatment rather than chasing down and possibly breaking whatever
  # actually depends on it.
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
