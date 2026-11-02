-- nixpkgs patches in the tinymist and websocat paths.
local opts = {}

-- Its own --user-data-dir makes Brave start a separate instance even when the
-- main one is open; --app drops tabs/toolbar. Elsewhere (e.g. wsl) keep the
-- plugin's default opener.
if vim.fn.executable("brave-origin") == 1 then
  local profile = vim.fn.shellescape(vim.fn.stdpath("cache") .. "/preview-browser")
  opts.open_cmd = "brave-origin --user-data-dir=" .. profile .. " --app=%s"
end

require("typst-preview").setup(opts)

-- The plugin only announces stopping; mirror its message on start.
require("core.util.keymap").map("n", "<leader>p", function()
  local path = vim.api.nvim_buf_get_name(0)
  local starting = path ~= "" and require("typst-preview.servers").get(path) == nil

  vim.cmd("TypstPreviewToggle")

  if starting then
    vim.schedule(function()
      print("Preview started")
    end)
  end
end, "Typst: Toggle [P]review")
