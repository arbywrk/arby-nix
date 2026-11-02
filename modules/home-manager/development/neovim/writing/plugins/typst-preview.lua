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
