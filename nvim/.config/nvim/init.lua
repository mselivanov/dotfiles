vim.lsp.enable({ "lua_ls", "ruff", "ty" })

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("plugins")
require("config.lsp")

vim.lsp.inline_completion.enable(false)

pcall(function()
	require("local")
end)
