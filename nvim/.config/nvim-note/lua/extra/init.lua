return {
	{
		"preservim/vim-markdown",
		branch = "master",
		dependencies = {
			"godlygeek/tabular",
		},
	},
	{
		"ellisonleao/glow.nvim",
		config = true,
		cmd = "Glow",
	},
	{
		"iamcco/markdown-preview.nvim",
		event = { "BufReadPost", "BufNewFile" },
	},
}
