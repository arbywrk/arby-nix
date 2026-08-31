-- Zellij intercepts Ctrl+h/j/k/l itself (see
-- modules/home-manager/development/zellij/default.nix) so it can move pane
-- focus when a non-vim pane is active. While a normal nvim buffer has
-- focus, switch Zellij into "locked" mode instead, so it stops intercepting
-- and those keys reach smart-splits.nvim directly -- no keystroke-forwarding
-- plugin needed. Zellij forwards its own pane-focus in/out to the focused
-- pane as terminal focus events, which is what FocusGained/FocusLost below
-- react to (not just OS-level window focus).
if vim.env.ZELLIJ then
    local group = vim.api.nvim_create_augroup("zellij-autolock", { clear = true })

    local function zellij_switch_mode(mode)
        vim.system({ "zellij", "action", "switch-mode", mode })
    end

    vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
        group = group,
        callback = function()
            zellij_switch_mode("locked")
        end,
    })

    vim.api.nvim_create_autocmd({ "VimLeavePre", "FocusLost" }, {
        group = group,
        callback = function()
            zellij_switch_mode("normal")
        end,
    })
end
