-- Format-on-save + manual format, dispatching to real formatter binaries
-- per filetype (mostly from neovim/packages.nix; rustfmt and zigfmt need
-- the project's toolchain on PATH). Setup options:
-- https://github.com/stevearc/conform.nvim#setup
local keymap = require("util.keymap")

keymap.map("", "<leader>f", function()
  require("conform").format({ async = true })
end, "[F]ormat buffer")

keymap.map("n", "<leader>uf", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  print("Format-on-save: " .. (vim.b.disable_autoformat and "off" or "on"))
end, "Toggle [U]I: [F]ormat-on-save")

-- Fall back to 2-space indents only when the project has no style config of
-- its own -- CLI flags would override it otherwise.
local function unless_configured(config_files, fallback_args)
  return function(_, ctx)
    if vim.fs.find(config_files, { upward = true, path = ctx.dirname })[1] then
      return {}
    end
    return fallback_args
  end
end

-- sqlfluff takes ~0.6s (Python startup).
local slow_fts = { sql = true }

require("conform").setup({
  notify_on_error = false,
  formatters = {
    stylua = {
      prepend_args = unless_configured(
        { "stylua.toml", ".stylua.toml", ".editorconfig" },
        { "--indent-type", "Spaces", "--indent-width", "2" }
      ),
    },
    -- Layout only (not `fix`'s lint rewrites), and also outside projects
    -- with a .sqlfluff -- the user-wide one in ~/.config/sqlfluff applies.
    sqlfluff = {
      args = { "format", "-" },
      require_cwd = false,
    },
    -- Replaces conform's default args, which use the buffer's shiftwidth.
    shfmt = {
      args = function(_, ctx)
        return vim.list_extend(
          { "-filename", "$FILENAME" },
          unless_configured({ ".editorconfig" }, { "-i", "2" })(_, ctx)
        )
      end,
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    python = { "ruff_format" },
    zig = { "zigfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    nix = { "nixfmt" },
    toml = { "taplo" },
    json = { "jq" },
    typst = { "typstyle" },
    sql = { "sqlfluff" },
    -- Any other filetype (e.g. C/C++ via clangd): the LSP's formatter if
    -- one is attached, otherwise just trim trailing whitespace.
    ["_"] = { "trim_whitespace", lsp_format = "prefer" },
  },
  -- A listed formatter that isn't installed falls back to the LSP's.
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function(bufnr)
    if vim.b[bufnr].disable_autoformat or slow_fts[vim.bo[bufnr].filetype] then
      return
    end
    return { timeout_ms = 500 }
  end,
  -- Slow formatters run after the write instead, then save again, so
  -- saving never blocks on them.
  format_after_save = function(bufnr)
    if vim.b[bufnr].disable_autoformat or not slow_fts[vim.bo[bufnr].filetype] then
      return
    end
    return {}
  end,
})
