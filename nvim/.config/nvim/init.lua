vim.lsp.enable({ "lua_ls", "ruff", "ty" })

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("plugins")
require("config.lsp")

vim.lsp.inline_completion.enable(false)
vim.g.clipboard = {
	name = "win32yank-wsl",
	copy = {
		["+"] = { "win32yank.exe", "-i", "--crlf" },
		["*"] = { "win32yank.exe", "-i", "--crlf" },
	},
	paste = {
		["+"] = { "win32yank.exe", "-o", "--lf" },
		["*"] = { "win32yank.exe", "-o", "--lf" },
	},
	cache_enabled = 0,
}

pcall(function()
	require("local")
end)
