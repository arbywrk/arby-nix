-- Uses Neovim's own built-in LSP client config (`vim.lsp.config`/`vim.lsp.enable`,
-- :help lsp-config) -- not nvim-lspconfig's older `require('lspconfig').x.setup{}`
-- pattern you'll see in most tutorials. Per-server settings tables are the
-- same shape either way; see :help lsp-quickstart and each server's own docs.
-- Profiles call M.enable() with their servers; the attach keymaps are shared.
local keymap = require("core.util.keymap")
local attach_group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true })
local highlight_group = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })
local detach_group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = false })

vim.api.nvim_create_autocmd("LspAttach", {
  group = attach_group,
  callback = function(event)
    local map = function(keys, func, desc, mode)
      keymap.buffer_map(event.buf, mode or "n", keys, func, "LSP: " .. desc)
    end

    map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
    map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
    map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
    map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = event.buf })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_clear_autocmds({ group = detach_group, buffer = event.buf })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = detach_group,
        buffer = event.buf,
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({
            group = highlight_group,
            buffer = event2.buf,
          })
        end,
      })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map("<leader>ui", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "Toggle [I]nlay Hints")
    end
  end,
})

local M = {}

-- Enabled in every profile, on top of the servers it passes to M.enable().
-- Binaries come from core.packages in core/default.nix.
local shared_servers = {
  marksman = {}, -- Markdown: heading/link completion, go-to-definition, references
}

local function warn_missing(server_name, cmd, filetypes, install_hint)
  if not filetypes then
    return
  end
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user-lsp-missing-" .. server_name, { clear = true }),
    pattern = filetypes,
    once = true, -- one popup per session, not per buffer
    callback = function()
      vim.notify(
        ("`%s` not on PATH -- install %s, or open nvim inside the project's devShell"):format(
          cmd[1],
          install_hint or cmd[1]
        ),
        vim.log.levels.WARN,
        { title = "LSP: " .. server_name }
      )
    end,
  })
end

-- servers: name -> vim.lsp.config table. install_hints: name -> what to
-- install, for servers expected from a project toolchain rather than Nix.
-- Checked against the PATH nvim started with, so open it inside the
-- project's direnv to pick up project-provided servers.
function M.enable(servers, install_hints)
  local capabilities = require("blink.cmp").get_lsp_capabilities()
  install_hints = install_hints or {}
  servers = vim.tbl_extend("error", shared_servers, servers)

  for server_name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
    vim.lsp.config(server_name, server)
    local config = vim.lsp.config[server_name]
    if type(config.cmd) ~= "table" or vim.fn.executable(config.cmd[1]) == 1 then
      vim.lsp.enable(server_name)
    else
      warn_missing(server_name, config.cmd, config.filetypes, install_hints[server_name])
    end
  end
end

return M
