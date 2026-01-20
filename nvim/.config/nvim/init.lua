require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("plugins")

pcall(function()
	require("local")
end)
