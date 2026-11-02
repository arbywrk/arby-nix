local keymap = require("core.util.keymap")

-- Move by display line through soft-wrapped paragraphs; counts (5j) still
-- move by real lines.
keymap.map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", "Down (display line)", { expr = true })
keymap.map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", "Up (display line)", { expr = true })

keymap.map("n", "<leader>p", "<cmd>TypstPreviewToggle<cr>", "Typst: Toggle [P]review")

keymap.map("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, "[F]ormat buffer")
