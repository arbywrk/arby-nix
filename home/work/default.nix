{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
  ];

  home.username = "bogdanrares";
  home.homeDirectory = "/home/bogdanrares";

  home.stateVersion = "26.05";

  xdg.enable = true;

  # Git config on this profile is managed outside this repo (work-specific
  # setup), not by home-manager.

  # Work-only LSP servers -- kept out of the shared neovim module (see
  # modules/home-manager/development/neovim) since neither is relevant on
  # the personal profile: dts-lsp only matters for Zephyr devicetree work,
  # and registering yamlls here (rather than in the shared servers table)
  # keeps it from ever trying to start against a YAML file on that profile.
  home.packages = [
    pkgs.dts-lsp
    pkgs.yaml-language-server
  ];

  # programs.neovim.initLua is `types.lines`, concatenated across every
  # module that sets it, ordered by `lib.mkOrder` priority (lower =
  # earlier). home-manager's own neovim module already wraps the
  # "advised plugin config" block (every plugins.*.config string --
  # blink.cmp's setup() included) in `lib.mkAfter`, i.e. order 1500 --
  # confirmed by reading modules/programs/neovim/default.nix in the
  # pinned home-manager source. Using `mkAfter` here too would only tie
  # at 1500, and ties fall back to declaration order, which happens to
  # put this block first regardless -- so this needs a strictly higher
  # order to actually land after it and guarantee blink.cmp is already
  # set up before get_lsp_capabilities() runs below.
  programs.neovim.initLua = lib.mkOrder 1600 ''
    do
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Zephyr devicetree overlays (.dts/.dtsi/.overlay) -- see
      -- https://github.com/igor-prusov/dts-lsp. No extra settings needed.
      vim.lsp.config("dts_lsp", { capabilities = capabilities })
      vim.lsp.enable("dts_lsp")

      -- Zuul CI pipeline/job YAML (zuul.d/*.yaml, .zuul.yaml, ...). Schema
      -- is a community-maintained one (not yet in SchemaStore) -- swap for
      -- an internal schema URL here if one exists at work.
      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              ["https://raw.githubusercontent.com/pycontribs/zuul-lint/master/zuul_lint/zuul-schema.json"] = {
                "zuul.d/*.yaml",
                "zuul.d/*.yml",
                ".zuul.yaml",
                "zuul-extra.d/*.yaml",
              },
            },
          },
        },
      })
      vim.lsp.enable("yamlls")
    end
  '';

  programs.home-manager.enable = true;
}
