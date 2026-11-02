-- Prose on top of core.options: soft-wrap at word boundaries, spell-check.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.spell = true
vim.opt.spelllang = { "en" }

-- Neovim core has no built-in filetype detection for .typ yet.
vim.filetype.add({ extension = { typ = "typst" } })
