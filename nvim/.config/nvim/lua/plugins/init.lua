return {
	-- Auxiliary functions: async, path, OS interaction
	"nvim-lua/plenary.nvim",
	-- UI library
	"MunifTanjim/nui.nvim",
	{ "nvim-tree/nvim-web-devicons" },
	-- Collection of icons for plugins
	{ "tpope/vim-repeat", event = "VeryLazy" },
	-- Peeking the line while entering line number in the command line
	{ "nacro90/numb.nvim", event = "BufReadPre", config = true },
	{
		-- Show blankline indentation
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			char = "│",
			filetype_exclude = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy" },
			show_trailing_blankline_indent = false,
			show_current_context = false,
		},
		config = function()
			require("ibl").setup()
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
	{
		-- Increment/decrement numbers, dates, booleans
		"monaqa/dial.nvim",
		keys = {
			{ "<C-a>", mode = { "n", "v" } },
			{ "<C-x>", mode = { "n", "v" } },
			{ "g<C-a>", mode = { "v" } },
			{ "g<C-x>", mode = { "v" } },
		},
    -- stylua: ignore
    init = function()
      vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal(), { desc = "Increment", noremap = true })
      vim.api.nvim_set_keymap("n", "<C-x>", require("dial.map").dec_normal(), { desc = "Decrement", noremap = true })
      vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual(), { desc = "Increment", noremap = true })
      vim.api.nvim_set_keymap("v", "<C-x>", require("dial.map").dec_visual(), { desc = "Decrement", noremap = true })
      vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual(), { desc = "Increment", noremap = true })
      vim.api.nvim_set_keymap("v", "g<C-x>", require("dial.map").dec_gvisual(), { desc = "Decrement", noremap = true })
    end,
	},
	{
		-- Advanced matching
		"andymass/vim-matchup",
		event = { "BufReadPost" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
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
}
