-- Server settings: see :help lsp-quickstart and each server's own docs
-- (e.g. clangd: https://clangd.llvm.org/config). Attach keymaps and the
-- enable loop live in core.lsp.
local clangd = require("config.lsp.clangd")

-- Most servers come from nixpkgs (see packages.nix), not Mason. Ones tied to
-- a project toolchain (zls) are expected on PATH from the project itself.
local servers = {
  clangd = clangd.server_config(),

  zls = {},
  bashls = {},
  taplo = {},
  -- Completion against a live DB; reads .sqls/config.yml for connections.
  sqls = {},
  -- Postgres syntax/lint diagnostics; only attaches in projects with a
  -- postgres-language-server.jsonc.
  postgres_lsp = {},

  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "standard",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  },

  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },

  -- Zephyr devicetree overlays (.dts/.dtsi/.overlay) -- see
  -- https://github.com/igor-prusov/dts-lsp. No extra settings needed.
  dts_lsp = {},

  -- Expressions come from coding/default.nix, pinned to this flake's inputs.
  nixd = {
    settings = {
      nixd = {
        nixpkgs = { expr = vim.g.nixd_nixpkgs_expr },
        formatting = { command = { "nixfmt" } },
        options = {
          nixos = { expr = vim.g.nixd_nixos_options_expr },
          home_manager = { expr = vim.g.nixd_home_manager_options_expr },
          flake_parts = { expr = vim.g.nixd_flake_parts_options_expr },
        },
      },
    },
  },

  yamlls = {
    settings = {
      yaml = {
        schemas = {
          -- Zuul CI pipeline/job YAML (zuul.d/*.yaml, .zuul.yaml, ...).
          -- Schema is a community-maintained one (not yet in
          -- SchemaStore) -- swap for an internal schema URL here if
          -- one exists at work.
          ["https://raw.githubusercontent.com/pycontribs/zuul-lint/master/zuul_lint/zuul-schema.json"] = {
            "zuul.d/*.yaml",
            "zuul.d/*.yml",
            ".zuul.yaml",
            "zuul-extra.d/*.yaml",
          },
        },
      },
    },
  },
}

require("core.lsp").enable(servers, {
  zls = "zls matching the project's zig version",
})
