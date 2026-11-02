-- Parsers are bundled at build time via each profile's grammar list
-- (core.treesitter in core/default.nix) -- no runtime :TSInstall / .install()
-- call needed (or wanted: that would mean a network fetch at edit-time).
require("nvim-treesitter").setup()

-- nvim-treesitter's main branch doesn't start highlighting by itself.
-- pcall: filetypes without a bundled parser keep regex syntax.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("core-treesitter", { clear = true }),
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
  end,
})
