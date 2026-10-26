-- rust-analyzer comes from the project toolchain (rustup or a devShell), not
-- packages.nix, so skip attaching with a one-time hint when it's missing.
local warned = false

vim.g.rustaceanvim = {
  server = {
    auto_attach = function()
      if vim.fn.executable("rust-analyzer") == 1 then
        return true
      end
      if not warned then
        warned = true
        vim.notify(
          "`rust-analyzer` not on PATH -- run `rustup component add rust-analyzer`, or open nvim inside the project's devShell",
          vim.log.levels.WARN,
          { title = "LSP: rust-analyzer" }
        )
      end
      return false
    end,
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
      },
    },
  },
}
