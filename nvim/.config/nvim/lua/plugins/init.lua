return {
	-- Auxiliary functions: async, path, OS interaction
	"nvim-lua/plenary.nvim",
	{ "nvim-tree/nvim-web-devicons" },
	{
		-- Advanced matching
		"andymass/vim-matchup",
		event = { "BufReadPost" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	{
		-- Improve UI
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			input = { relative = "editor" },
			select = {
				backend = { "telescope", "fzf", "builtin" },
			},
		},
	},
	-- Delete/change parentheses, tags and else
	{ "tpope/vim-surround", event = "BufReadPre" },
	-- Git integration
	{ "tpope/vim-fugitive", event = "BufReadPre" },
	{
		-- Comment plugin
		"numToStr/Comment.nvim",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		keys = { { "gc", mode = { "n", "v" } }, { "gcc", mode = { "n", "v" } }, { "gbc", mode = { "n", "v" } } },
		config = function(_, _)
			local opts = {
				ignore = "^$",
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
			require("Comment").setup(opts)
		end,
	},
	{ "echasnovski/mini.nvim", version = false },
}
