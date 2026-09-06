local M = {}

local project_root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    ".git",
}

local function read_style_file(path)
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok then
        return {}
    end

    local style = {}

    for _, line in ipairs(lines) do
        local indent_width = line:match("^%s*IndentWidth:%s*(%d+)")
        if indent_width then
            style.indent_width = tonumber(indent_width)
        end

        local tab_width = line:match("^%s*TabWidth:%s*(%d+)")
        if tab_width then
            style.tab_width = tonumber(tab_width)
        end

        local use_tab = line:match("^%s*UseTab:%s*(%S+)")
        if use_tab then
            style.use_tab = use_tab
        end
    end

    return style
end

local function find_style_file(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return nil
    end

    return vim.fs.find({ ".clang-format", "_clang-format" }, {
        path = vim.fs.dirname(filename),
        upward = true,
    })[1]
end

local function clangd_cmd()
    return {
        "clangd",
        "--background-index",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--clang-tidy",
        "--header-insertion=iwyu",
    }
end

local function normalize_bufname(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return nil
    end

    return vim.fs.normalize(filename)
end

function M.find_project_root(fname)
    return vim.fs.root(fname, project_root_markers)
end

function M.root_dir(bufnr, on_dir)
    local filename = normalize_bufname(bufnr)
    if not filename then
        return
    end

    local root_dir = M.find_project_root(filename)
    if root_dir then
        on_dir(root_dir)
        return
    end

    -- Keep standalone C/C++ files working outside a detected workspace.
    on_dir(vim.fs.dirname(filename))
end

function M.server_config()
    return {
        cmd = clangd_cmd(),
        root_dir = M.root_dir,
    }
end

function M.on_attach(client, bufnr)
    if not client or client.name ~= "clangd" then
        return
    end

    -- Format-on-save for C/C++ goes through conform's LSP-fallback path
    -- (plugins/conform.lua) instead of a bespoke autocmd here, so it's
    -- subject to the same toggle as every other filetype.

    local style_file = find_style_file(bufnr)
    local style = style_file and read_style_file(style_file) or {}
    local indent_width = style.indent_width or 2
    local tab_width = style.tab_width or indent_width

    -- Mirror project style locally so manual edits match clang-format output.
    vim.bo[bufnr].tabstop = tab_width
    vim.bo[bufnr].shiftwidth = indent_width
    vim.bo[bufnr].softtabstop = indent_width

    if style.use_tab == "Never" then
        vim.bo[bufnr].expandtab = true
    elseif style.use_tab == "Always" then
        vim.bo[bufnr].expandtab = false
    end
end

return M
