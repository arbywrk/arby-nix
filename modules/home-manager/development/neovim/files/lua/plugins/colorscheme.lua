-- Transparent backgrounds so the terminal's (stylix-themed) background
-- shows through.
require("ayu").setup({
  overrides = {
    Normal = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    SignColumn = { bg = "NONE" },
    EndOfBuffer = { bg = "NONE" },
    -- ayu's LineNr is nearly invisible on a near-black background.
    LineNr = { fg = "#636A72" },
  },
})

vim.cmd.colorscheme("ayu-dark")
