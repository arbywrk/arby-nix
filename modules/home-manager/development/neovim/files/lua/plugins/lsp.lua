-- Uses Neovim's own built-in LSP client config (`vim.lsp.config`/`vim.lsp.enable`,
-- :help lsp-config) -- not nvim-lspconfig's older `require('lspconfig').x.setup{}`
-- pattern you'll see in most tutorials. Per-server settings tables here are the
-- same shape either way; see :help lsp-quickstart and each server's own docs
-- (e.g. clangd: https://clangd.llvm.org/config) for what's available.
local clangd = require("config.lsp.clangd")
local keymap = require("util.keymap")
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

        clangd.on_attach(client, event.buf)
    end,
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Every server here comes from nixpkgs (see packages.nix), not
-- Mason -- installed declaratively, no runtime download.
local servers = {
    clangd = clangd.server_config(),

    zls = {},
    bashls = {},
    nil_ls = {},
    taplo = {},
    sqls = {},

    basedpyright = {
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "standard",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                },
            },
        },
    },

    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = "Replace",
                },
            },
        },
    },

    -- Zephyr devicetree overlays (.dts/.dtsi/.overlay) -- see
    -- https://github.com/igor-prusov/dts-lsp. No extra settings needed.
    dts_lsp = {},

    tinymist = {},

    yamlls = {
        settings = {
            yaml = {
                schemas = {
                    -- Zuul CI pipeline/job YAML (zuul.d/*.yaml, .zuul.yaml, ...).
                    -- Schema is a community-maintained one (not yet in
                    -- SchemaStore) -- swap for an internal schema URL here if
                    -- one exists at work.
                    ["https://raw.githubusercontent.com/pycontribs/zuul-lint/master/zuul_lint/zuul-schema.json"] = {
                        "zuul.d/*.yaml",
                        "zuul.d/*.yml",
                        ".zuul.yaml",
                        "zuul-extra.d/*.yaml",
                    },
                },
            },
        },
    },
}

for server_name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
    vim.lsp.config(server_name, server)
    vim.lsp.enable(server_name)
end
