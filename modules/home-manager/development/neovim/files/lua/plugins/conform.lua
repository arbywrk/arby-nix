local keymap = require("util.keymap")

keymap.map("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "[F]ormat buffer")

-- Single tri-state cycle instead of independent toggles: formatters
-- (including clang-format, via clangd's LSP-fallback formatting -- see
-- config/lsp/clangd.lua) and trailing-whitespace trimming are different
-- enough in severity that "everything at once" needed a middle ground.
-- Buffer-local, falling back to a global default (vim.g.format_state) so a
-- filetype/project autocmd could set a repo-wide default if ever needed.
local STATE = { ENABLED = 0, FORMATTERS_DISABLED = 1, ALL_DISABLED = 2 }
local STATE_MESSAGE = {
	[STATE.ENABLED] = "Formatting: all enabled",
	[STATE.FORMATTERS_DISABLED] = "Formatting: formatters disabled, trim still on",
	[STATE.ALL_DISABLED] = "Formatting: all disabled",
}

local function current_state(bufnr)
	local b = vim.b[bufnr].format_state
	if b ~= nil then
		return b
	end
	return vim.g.format_state or STATE.ENABLED
end

keymap.map("n", "<leader>uf", function()
	local next_state = (current_state(0) + 1) % 3
	vim.b.format_state = next_state
	print(STATE_MESSAGE[next_state])
end, "Toggle [U]I: cycle [F]ormat-on-save (all -> formatters off -> all off)")

-- Formatters, kept per-filetype so format_on_save below can also read
-- them when building an explicit list. C/C++ has no entry here -- it's
-- handled by clangd via lsp_format below.
local formatters_by_ft = {
	lua = { "stylua" },
	python = { "ruff_format" },
	zig = { "zigfmt" },
	sh = { "shfmt" },
	bash = { "shfmt" },
	nix = { "nixfmt" },
	toml = { "taplo" },
	json = { "jq" },
}

require("conform").setup({
	notify_on_error = false,
	formatters_by_ft = vim.tbl_extend("force", formatters_by_ft, { ["*"] = { "trim_whitespace" } }),
	format_on_save = function(bufnr)
		local ft = vim.bo[bufnr].filetype
		local state = current_state(bufnr)
		local autoformat_enabled = state == STATE.ENABLED
		local trim_ws_enabled = state ~= STATE.ALL_DISABLED

		if not autoformat_enabled and not trim_ws_enabled then
			return
		end

		local formatters = {}
		if trim_ws_enabled then
			table.insert(formatters, "trim_whitespace")
		end
		if autoformat_enabled and formatters_by_ft[ft] then
			vim.list_extend(formatters, formatters_by_ft[ft])
		end

		return {
			formatters = formatters,
			timeout_ms = 500,
			lsp_format = autoformat_enabled and "fallback" or "never",
		}
	end,
})
