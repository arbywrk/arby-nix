-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Autocenter on half page jump
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", "")
vim.keymap.set("n", "<right>", "")
vim.keymap.set("n", "<up>", "")
vim.keymap.set("n", "<down>", "")

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- CTRL+SHIFT+<hjkl> to reorganize (move) the current window to the far
-- edge in that direction, using nvim's own builtin <C-w>H/J/K/L -- mirrors
-- Ctrl+Shift+h/j/k/l in zellij (see modules/home-manager/development/zellij),
-- which does the equivalent MovePane there. Confirmed free of collisions
-- (nothing else in this config binds <C-S-h/j/k/l> or their capitalized
-- <C-H/J/K/L> form). Requires the terminal to report Ctrl and Shift as
-- distinguishable from plain Ctrl -- if it can't, these keys simply won't
-- fire and <C-h/j/k/l> above still works as normal focus-movement.
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the far left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the far right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the bottom" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the top" })

-- ALT+<hjkl> to resize the current window -- h/l adjust width, j/k adjust
-- height (there's no builtin "grow toward this specific screen edge" the
-- way zellij's resize mode has; nvim's own :resize/:vertical resize just
-- grow/shrink the current window along one axis, so that's what these
-- map to). Confirmed free of collisions -- nothing else in this config
-- binds <A-h/j/k/l>.
vim.keymap.set("n", "<A-h>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<A-l>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<A-j>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<A-k>", "<cmd>resize +2<CR>", { desc = "Increase window height" })

-- ]t / [t to move between tab pages -- same bracket-motion convention
-- gitsigns already uses for hunks (]h/[h, see plugins/gitsigns.lua), and
-- distinct from the buffer-cycling <leader>bn/<leader>bp
-- (keymaps/buffer.lua) since tab pages and buffers are different things.
-- <leader>t was already claimed by the [T]est group (plugins/neotest.lua),
-- so this isn't a <leader> mapping.
vim.keymap.set("n", "]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "[t", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Switch between light and dark mode
vim.keymap.set("n", "<leader>ut", function()
    if vim.o.background == "dark" then
        vim.o.background = "light"
    else
        vim.o.background = "dark"
    end
    print("Switched to " .. vim.o.background .. " mode")
end, { desc = "Toggle Light/Dark Mode" })

-- Use :w!! to write sudo file
vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %", { desc = "Write file with sudo" })

require("keymaps.window")
require("keymaps.buffer")
require("keymaps.build")
