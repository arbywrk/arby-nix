# Writing-only plugins (core/ supplies the shared ones).
{ pkgs, nvimLib }:
let
  inherit (nvimLib) luaPlugin;
  p = pkgs.vimPlugins;
  file = name: builtins.readFile ./plugins/${name}.lua;
  runtime = nvimLib.mkRuntime "nvim-writing-lua" ./runtime;
in
[
  runtime

  (luaPlugin p.luasnip "require('luasnip.loaders.from_lua').lazy_load({ paths = { '${runtime}/luasnippets' } })")
  (luaPlugin p.blink-cmp (file "blink-cmp"))
  (luaPlugin p.nvim-lspconfig (file "lsp"))
  (luaPlugin p.lualine-nvim (file "lualine"))
  # nixpkgs patches in the tinymist and websocat paths.
  (luaPlugin p.typst-preview-nvim "require('typst-preview').setup({})")
]
