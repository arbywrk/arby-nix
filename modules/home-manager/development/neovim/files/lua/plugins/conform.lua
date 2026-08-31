local keymap = require("util.keymap")

keymap.map("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "[F]ormat buffer")

-- Two independent, default-enabled toggles: disabling autoformat for a
-- noisy legacy repo shouldn't also stop trimming trailing whitespace,
-- since that's not the kind of change autoformat-disable is guarding
-- against. Mirrors conform.nvim's own documented FormatDisable/FormatEnable
-- recipe -- bang = buffer-local, no bang = global.
vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, { desc = "Disable autoformat-on-save", bang = true })
vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, { desc = "Re-enable autoformat-on-save" })

vim.api.nvim_create_user_command("TrimTrailingWhitespaceDisable", function(args)
	if args.bang then
		vim.b.disable_trim_trailing_whitespace = true
	else
		vim.g.disable_trim_trailing_whitespace = true
	end
end, { desc = "Disable trailing-whitespace trim on save", bang = true })
vim.api.nvim_create_user_command("TrimTrailingWhitespaceEnable", function()
	vim.b.disable_trim_trailing_whitespace = false
	vim.g.disable_trim_trailing_whitespace = false
end, { desc = "Re-enable trailing-whitespace trim on save" })

keymap.map("n", "<leader>uf", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	print("Autoformat " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for this buffer")
end, "Toggle [U]I: Auto[F]ormat on save")

keymap.map("n", "<leader>uw", function()
	vim.b.disable_trim_trailing_whitespace = not vim.b.disable_trim_trailing_whitespace
	print(
		"Trim trailing "
			.. "whitespace "
			.. (vim.b.disable_trim_trailing_whitespace and "disabled" or "enabled")
			.. " for this buffer"
	)
end, "Toggle [U]I: Trim trailing [W]hitespace on save")

-- Formatters, kept per-filetype so format_on_save below can also read
-- them when building an explicit list for the two toggles above.
local formatters_by_ft = {
	lua = { "stylua" },
	python = { "ruff_format" },
	zig = { "zig" },
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
		local autoformat_enabled = not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat)
		local trim_ws_enabled = not (
			vim.g.disable_trim_trailing_whitespace or vim.b[bufnr].disable_trim_trailing_whitespace
		)

		local formatters = {}
		if trim_ws_enabled then
			table.insert(formatters, "trim_whitespace")
		end
		if autoformat_enabled and formatters_by_ft[ft] then
			vim.list_extend(formatters, formatters_by_ft[ft])
		end
		if #formatters == 0 then
			return
		end

		local disable_lsp_filetypes = { c = true, cpp = true }
		return {
			formatters = formatters,
			timeout_ms = 500,
			lsp_format = (autoformat_enabled and not disable_lsp_filetypes[ft]) and "fallback" or "never",
		}
	end,
})
