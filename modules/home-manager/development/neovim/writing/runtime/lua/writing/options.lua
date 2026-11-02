-- Prose on top of core.options: spell-check.
vim.opt.spell = true
vim.opt.spelllang = { "en" }

-- Neovim core has no built-in filetype detection for .typ yet.
vim.filetype.add({ extension = { typ = "typst" } })
