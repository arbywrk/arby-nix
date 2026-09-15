-- Ayu Dark -- same palette as ghostty.nix and zellij's ayu-dark.kdl, so
-- nvim looks in place inside the terminal. overrides strip backgrounds
-- from the surfaces vague's own `transparent = true` used to cover, so
-- the terminal's own background shows through instead.
require("ayu").setup({
    overrides = {
        Normal = { bg = "NONE" },
        NormalNC = { bg = "NONE" },
        NormalFloat = { bg = "NONE" },
        SignColumn = { bg = "NONE" },
        EndOfBuffer = { bg = "NONE" },
        -- ayu's own LineNr color (guide_normal, #1E222A) is meant for faint
        -- indent guides, not gutter numbers -- against this near-black
        -- background it's practically invisible. Comment gray actually reads.
        LineNr = { fg = "#636A72" },
    },
})

vim.cmd.colorscheme("ayu-dark")
