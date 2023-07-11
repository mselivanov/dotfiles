return {
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		enabled = true,
		config = function()
			vim.g.nord_contrast = true
			vim.g.nord_borders = true
			vim.g.nord_disable_background = false
			vim.g.nord_italic = false
			vim.g.nord_uniform_diff_background = true
			vim.g.nord_bold = false
			local nord = require("nord")
			nord.set()
		end,
	},
}
