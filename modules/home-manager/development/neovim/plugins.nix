# Maps lua/plugins/*.lua onto nixpkgs.vimPlugins, replacing lazy.nvim.
# Loading is eager (no lazy-loading layer -- accepted tradeoff, see
# implementation plan), so every plugin here is just added to the
# runtimepath; the ones that need setup() get their (trimmed, wrapper-free)
# lua/plugins/*.lua file wired in as `config`, which home-manager embeds
# as native Lua (programs.neovim.plugins.*.type defaults to "lua" at
# home.stateVersion >= 26.05 -- no vimscript `lua << EOF` heredoc wrapper
# needed here, unlike older home-manager releases).
{ pkgs }:
let
  toLuaFile = file: builtins.readFile file;
  toLua = str: str;
  p = pkgs.vimPlugins;

  treesitterWithGrammars = p.nvim-treesitter.withPlugins (
    ps: with ps; [
      bash
      c
      cpp
      diff
      lua
      luadoc
      nix
      python
      query
      toml
      vim
      vimdoc
      rust
      ron
      sql
      zig
    ]
  );
in
[
  # Pure dependencies: other plugins require() these directly, nothing of
  # our own to configure.
  p.nvim-nio
  p.plenary-nvim
  p.nvim-web-devicons
  p.nui-nvim
  p.friendly-snippets
  p.vim-sleuth # no Lua config at all -- runs via its own plugin/sleuth.vim

  # Configured plugins.
  {
    plugin = p.blink-cmp;
    config = toLuaFile ./files/lua/plugins/blink-cmp.lua;
  }
  {
    plugin = p.lazydev-nvim;
    config = toLua "require('lazydev').setup({ library = { 'nvim-dap-ui' } })";
  }
  {
    plugin = p.fidget-nvim;
    config = toLua "require('fidget').setup({})";
  }
  {
    plugin = p.nvim-lspconfig;
    config = toLuaFile ./files/lua/plugins/lsp.lua;
  }
  {
    plugin = p.nvim-colorizer-lua;
    config = toLuaFile ./files/lua/plugins/colorizer.lua;
  }
  {
    plugin = p.vague-nvim;
    config = toLuaFile ./files/lua/plugins/colorscheme.lua;
  }
  {
    plugin = p.conform-nvim;
    config = toLuaFile ./files/lua/plugins/conform.lua;
  }
  {
    plugin = p.crates-nvim;
    config = toLuaFile ./files/lua/plugins/crates.lua;
  }
  {
    plugin = p.nvim-dap;
    config = toLuaFile ./files/lua/plugins/debug.lua;
  }
  p.nvim-dap-ui
  p.nvim-dap-python
  p.nvim-dap-virtual-text
  {
    plugin = p.persistent-breakpoints-nvim;
    config = toLua "require('persistent-breakpoints').setup()";
  }
  {
    plugin = p.fzf-lua;
    config = toLuaFile ./files/lua/plugins/fzf-lua.lua;
  }
  {
    plugin = p.gitsigns-nvim;
    config = toLuaFile ./files/lua/plugins/gitsigns.lua;
  }
  {
    plugin = p.nvim-lint;
    config = toLuaFile ./files/lua/plugins/lint.lua;
  }
  {
    plugin = p.lualine-nvim;
    config = toLuaFile ./files/lua/plugins/lualine.lua;
  }
  {
    plugin = p.mini-nvim;
    config = toLuaFile ./files/lua/plugins/mini.lua;
  }
  {
    plugin = p.neotest;
    config = toLuaFile ./files/lua/plugins/neotest.lua;
  }
  p.neotest-python
  {
    plugin = p.neo-tree-nvim;
    config = toLuaFile ./files/lua/plugins/neo-tree.lua;
  }
  {
    plugin = p.nvim-notify;
    config = toLua "require('notify').setup({ stages = 'fade_in_slide_out', fps = 60, timeout = 500, render = 'minimal', top_down = false, background_colour = '#141415' })";
  }
  {
    plugin = p.noice-nvim;
    config = toLuaFile ./files/lua/plugins/noice.lua;
  }
  {
    plugin = p.rustaceanvim;
    config = toLuaFile ./files/lua/plugins/rustacean.lua;
  }
  {
    plugin = treesitterWithGrammars;
    config = toLuaFile ./files/lua/plugins/treesitter.lua;
  }
  {
    plugin = p.trouble-nvim;
    config = toLuaFile ./files/lua/plugins/trouble.lua;
  }
  {
    plugin = p.which-key-nvim;
    config = toLuaFile ./files/lua/plugins/which-key.lua;
  }
]
