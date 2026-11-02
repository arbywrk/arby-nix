local keymap = require("core.util.keymap")

keymap.map("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, "[F]ormat buffer")
