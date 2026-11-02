-- Shared blink.cmp defaults; each profile calls setup() with its own
-- sources (lists aren't merged, so a profile owns sources.default whole).
local M = {}

local defaults = {
  keymap = { preset = "default" },

  appearance = {
    nerd_font_variant = "mono",
  },

  completion = { documentation = { auto_show = false } },

  fuzzy = { implementation = "prefer_rust" },
}

function M.setup(opts)
  require("blink.cmp").setup(vim.tbl_deep_extend("force", defaults, opts or {}))
end

return M
