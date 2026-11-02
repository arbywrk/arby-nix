# Coding-only plugins (core/ supplies the shared ones). Loading is eager (no
# lazy-loading layer, accepted for simplicity); plugins needing setup() get
# their plugins/*.lua wired in as `config`.
{ pkgs, nvimLib }:
let
  inherit (nvimLib) luaPlugin;
  p = pkgs.vimPlugins;
  file = name: builtins.readFile ./plugins/${name}.lua;
in
[
  (nvimLib.mkRuntime "nvim-coding-lua" ./runtime)

  # Pure dependencies: other plugins require() these directly, nothing of
  # our own to configure.
  p.nvim-nio
  p.friendly-snippets
  p.vim-sleuth # no Lua config at all -- runs via its own plugin/sleuth.vim

  # Configured plugins.
  (luaPlugin p.blink-cmp (file "blink-cmp"))
  (luaPlugin p.lazydev-nvim "require('lazydev').setup({ library = { 'nvim-dap-ui' } })")
  (luaPlugin p.nvim-lspconfig (file "lsp"))
  (luaPlugin p.lualine-nvim (file "lualine"))
  (luaPlugin p.nvim-colorizer-lua (file "colorizer"))
  (luaPlugin p.conform-nvim (file "conform"))
  (luaPlugin p.crates-nvim (file "crates"))
  (luaPlugin p.nvim-dap (file "debug"))
  p.nvim-dap-ui
  p.nvim-dap-python
  p.nvim-dap-virtual-text
  (luaPlugin p.persistent-breakpoints-nvim "require('persistent-breakpoints').setup()")
  (luaPlugin p.gitsigns-nvim (file "gitsigns"))
  (luaPlugin p.nvim-lint (file "lint"))
  # Must precede neotest: its rustaceanvim adapter loads rustaceanvim's
  # config on require, freezing it before vim.g.rustaceanvim is set.
  (luaPlugin p.rustaceanvim (file "rustacean"))
  (luaPlugin p.neotest (file "neotest"))
  p.neotest-python
  (luaPlugin p.neo-tree-nvim (file "neo-tree"))
  (luaPlugin p.trouble-nvim (file "trouble"))
]
