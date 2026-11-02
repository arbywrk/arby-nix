# The writing profile: `nvim-writing` (alias `nw`), core plus Typst
# (tinymist, live preview, LuaSnip, fletcher). Its own NVIM_APPNAME keeps
# config/data/shada/undo apart from the coding nvim's.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  nvimLib = import ../lib.nix { inherit pkgs; };
  core = import ../core {
    inherit
      pkgs
      lib
      config
      nvimLib
      ;
  };

  # Pinned @preview packages; tinymist resolves imports from here instead of
  # downloading. The store is read-only, so new packages go in this list.
  typstPackages = pkgs.typst.withPackages (ps: [ ps.fletcher ]);

  nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    withPython3 = false;
    withRuby = false;

    plugins =
      core.plugins
      ++ [ (core.treesitter (ps: [ ps.typst ])) ]
      ++ import ./plugins.nix { inherit pkgs nvimLib; };

    # Runs before the plugin configs, so core's leader is set first.
    luaRcContent = ''
      ${core.initLua}
      vim.g.fletcher_version = "${pkgs.typstPackages.fletcher.version}"

      require("writing.options")
      require("writing.keymaps")
    '';

    wrapperArgs = [
      "--set"
      "NVIM_APPNAME"
      "nvim-writing"
      "--set"
      "TYPST_PACKAGE_CACHE_PATH"
      "${typstPackages}/lib/typst/packages"
      "--suffix"
      "PATH"
      ":"
      (lib.makeBinPath [ pkgs.tinymist ])
    ];
  };
in
{
  # Only the renamed binary: the wrapper's own bin/nvim would collide with
  # the coding nvim's.
  home.packages = [
    (pkgs.runCommand "nvim-writing" { } ''
      mkdir -p $out/bin
      ln -s ${nvim}/bin/nvim $out/bin/nvim-writing
    '')
  ];

  home.shellAliases.nw = "nvim-writing";
}
