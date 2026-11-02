-- Status line. Component/options reference:
-- https://github.com/nvim-lualine/lualine.nvim#default-configuration

-- Transparent bar with solid mode/location blocks colored by mode,
-- using stylix's palette so it matches the terminal and zellij.
local c = vim.g.base16_palette

local function mode_colors(accent)
  return {
    a = { fg = c.base00, bg = accent, gui = "bold" },
    b = { fg = accent, bg = "NONE" },
    c = { fg = c.base04, bg = "NONE" },
  }
end

local theme = {
  normal = mode_colors(c.base0D),
  insert = mode_colors(c.base0B),
  visual = mode_colors(c.base0E),
  replace = mode_colors(c.base08),
  command = mode_colors(c.base0A),
  terminal = mode_colors(c.base0C),
  inactive = {
    a = { fg = c.base03, bg = "NONE" },
    b = { fg = c.base03, bg = "NONE" },
    c = { fg = c.base03, bg = "NONE" },
  },
}

local M = {}

-- opts.components: extra lualine_x components, placed before the filetype.
-- opts.extensions: extra lualine extensions.
function M.setup(opts)
  opts = opts or {}

  local lualine_x = {
    { "searchcount", maxcount = 999 },
    { "selectioncount" },
    {
      function()
        local reg = vim.fn.reg_recording()

        if reg == "" then
          return ""
        end

        return "󰑋 @" .. reg
      end,
    },
  }
  vim.list_extend(lualine_x, opts.components or {})
  table.insert(lualine_x, { "filetype", colored = true, icon_only = false })

  require("lualine").setup({
    options = {
      theme = theme,
      globalstatus = true,

      icons_enabled = true,

      section_separators = "",
      component_separators = "",

      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },

      always_divide_middle = true,
      always_show_tabline = false,

      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
    },

    sections = {
      ------------------------------------------------------------------
      -- Mode
      ------------------------------------------------------------------
      lualine_a = {
        {
          "mode",
          icon = "",
        },
      },

      ------------------------------------------------------------------
      -- Git
      ------------------------------------------------------------------
      lualine_b = {
        {
          "branch",
          icon = "󰘬",
        },
        {
          "diff",
          symbols = {
            added = " ",
            modified = " ",
            removed = " ",
          },
        },
      },

      ------------------------------------------------------------------
      -- File
      ------------------------------------------------------------------
      lualine_c = {
        {
          function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end,
          icon = "",
        },

        {
          "filename",
          path = 1,
          symbols = {
            modified = " ●",
            readonly = " !",
            unnamed = "[No Name]",
          },
        },
      },

      ------------------------------------------------------------------
      -- Misc
      ------------------------------------------------------------------
      lualine_x = lualine_x,

      ------------------------------------------------------------------
      -- Diagnostics
      ------------------------------------------------------------------
      lualine_y = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },

          symbols = {
            error = " ",
            warn = " ",
            info = " ",
            hint = "󰌵 ",
          },

          update_in_insert = false,
        },

        {
          "encoding",
        },

        {
          "fileformat",
        },
      },

      ------------------------------------------------------------------
      -- Cursor
      ------------------------------------------------------------------
      lualine_z = {
        {
          "progress",
        },

        {
          "location",
        },
      },
    },

    inactive_sections = {
      lualine_a = {},
      lualine_b = {},

      lualine_c = {
        {
          "filename",
          path = 1,
        },
      },

      lualine_x = {
        {
          "location",
        },
      },

      lualine_y = {},
      lualine_z = {},
    },

    extensions = vim.list_extend({ "quickfix", "fzf" }, opts.extensions or {}),
  })
end

return M
