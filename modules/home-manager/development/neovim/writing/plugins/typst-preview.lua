-- nixpkgs patches in the tinymist and websocat paths.
require("typst-preview").setup({})

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
