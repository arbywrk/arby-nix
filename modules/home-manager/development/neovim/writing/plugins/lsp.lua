-- tinymist: diagnostics, completion and formatting (typstyle is built in).
-- Settings: https://github.com/Myriad-Dreamin/tinymist/blob/main/editors/neovim/README.md
require("core.lsp").enable({
  tinymist = {
    settings = {
      formatterMode = "typstyle",
    },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("writing-format-on-save", { clear = true }),
  pattern = "*.typ",
  callback = function(event)
    -- Skip quietly when tinymist isn't attached (e.g. still starting).
    if #vim.lsp.get_clients({ bufnr = event.buf, name = "tinymist" }) > 0 then
      vim.lsp.buf.format({ bufnr = event.buf, name = "tinymist", timeout_ms = 500 })
    end
  end,
})
