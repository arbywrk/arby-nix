-- Centered history screen over nvim-notify's history (noice routes popups
-- through it).
local M = {}

local ns = vim.api.nvim_create_namespace("user-notifications")

local function records()
  local ok, notify = pcall(require, "notify")
  return ok and notify.history() or {}
end

-- nvim-notify renderer: errors/warnings pop up as just their level, the rest
-- in full. The history keeps the full text either way.
local labels = { ERROR = "Error", WARN = "Warning" }
function M.render(bufnr, notif, highlights, config)
  local label = labels[notif.level]
  if label then
    notif = vim.tbl_extend("force", notif, { message = { notif.icon .. " " .. label } })
  end
  require("notify.render").minimal(bufnr, notif, highlights, config)
end

function M.statusline()
  local n = #records()
  return n > 0 and ("󰂚 " .. n) or ""
end

function M.open()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "notifications"

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.6)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Notifications ",
    title_pos = "center",
    footer = " C clear all · q close ",
    footer_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].cursorline = true

  local function render()
    local lines, highlights = {}, {}
    local list = records()
    for i = #list, 1, -1 do -- newest first
      local r = list[i]
      local time = os.date("%H:%M:%S", r.time)
      local label = r.icon .. " " .. (r.title[1] ~= "" and (r.title[1] .. ": ") or "")
      table.insert(lines, ("%s  %s%s"):format(time, label, r.message[1] or ""))
      table.insert(highlights, { #lines - 1, 0, #time, "Comment" })
      table.insert(highlights, { #lines - 1, #time + 2, #time + 2 + #label, "Notify" .. r.level .. "Title" })
      for j = 2, #r.message do
        table.insert(lines, "          " .. r.message[j])
      end
    end
    if #lines == 0 then
      lines = { "  No notifications" }
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for _, h in ipairs(highlights) do
      vim.api.nvim_buf_set_extmark(buf, ns, h[1], h[2], { end_col = h[3], hl_group = h[4] })
    end
  end

  local function map(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true })
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  map("C", function()
    require("notify").clear_history()
    require("notify").dismiss({ silent = true, pending = true })
    render()
  end)
  map("q", close)
  map("<Esc>", close)
  vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })

  render()
end

return M
