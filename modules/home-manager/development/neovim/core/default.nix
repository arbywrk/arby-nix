# Shared by the coding and writing profiles: only plugins whose config is
# identical in both live here. Plugins configured per profile (blink-cmp,
# lualine, nvim-lspconfig) are listed by each profile, whose config calls the
# matching core.* helper in runtime/lua/core.
{
  pkgs,
  lib,
  config,
  nvimLib,
}:
let
  inherit (nvimLib) luaPlugin;
  p = pkgs.vimPlugins;
  colors = config.lib.stylix.colors.withHashtag;
in
{
  plugins = [
    (nvimLib.mkRuntime "nvim-core-lua" ./runtime)

    p.plenary-nvim
    p.nvim-web-devicons
    p.nui-nvim

    (luaPlugin p.neovim-ayu (builtins.readFile ./plugins/colorscheme.lua))
    (luaPlugin p.fidget-nvim "require('fidget').setup({})")
    (luaPlugin p.fzf-lua (builtins.readFile ./plugins/fzf-lua.lua))
    (luaPlugin p.mini-nvim (builtins.readFile ./plugins/mini.lua))
    (luaPlugin p.nvim-notify "require('notify').setup({ stages = 'fade_in_slide_out', fps = 60, timeout = 500, render = 'minimal', top_down = false, background_colour = '${colors.base00}' })")
    (luaPlugin p.noice-nvim (builtins.readFile ./plugins/noice.lua))
    (luaPlugin p.which-key-nvim (builtins.readFile ./plugins/which-key.lua))
    # Renders headings, lists, code blocks and tables in the buffer.
    (luaPlugin p.render-markdown-nvim "require('render-markdown').setup({})")
  ];

  # Binaries core's Lua expects on PATH (marksman: core.lsp's shared server).
  # Each profile puts them there its own way.
  packages = [ pkgs.marksman ];

  # Parsers are per profile: `grammars` is a withPlugins selector (ps: [ ... ]).
  # Markdown is always added: render-markdown and noice's LSP hovers use it.
  treesitter =
    grammars:
    luaPlugin (p.nvim-treesitter.withPlugins (
      ps:
      grammars ps
      ++ [
        ps.markdown
        ps.markdown_inline
      ]
    )) (builtins.readFile ./plugins/treesitter.lua);

  # Must run before any plugin config: <leader> maps bind at definition time.
  initLua = ''
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.g.have_nerd_font = true

    -- stylix's base16 palette, for Lua configs that style themselves.
    vim.g.base16_palette = vim.json.decode([[${
      builtins.toJSON (lib.filterAttrs (name: _: builtins.match "base0[0-9A-F]" name != null) colors)
    }]])

    require("core.options")
    require("core.keymaps")
  '';
}
