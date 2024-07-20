return {
	{
		"mrjones2014/legendary.nvim",
		keys = {
			{ "<C-S-p>", "<cmd>Legendary<cr>", desc = "Legendary" },
			{ "<leader>hc", "<cmd>Legendary<cr>", desc = "Command Palette" },
		},
		opts = {
			which_key = { auto_register = true },
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
			{ "<leader>f", group = "find" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
			{ "<leader>ff", require("utils").find_files, desc = "Find Files" },
			{
				"<leader>fg",
				"<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>",
				desc = "Live grep",
			},
			{ "<leader>F", group = "files" },
			{ "<leader>Fr", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
			{ "<leader>Fe", "<cmd>NvimTreeToggle<cr>", desc = "File Tree" },
		},
	},
	-- {
	-- 	"folke/which-key.nvim",
	-- 	dependencies = {
	-- 		"mrjones2014/legendary.nvim",
	-- 	},
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		local wk = require("which-key")
	-- 		wk.setup({
	-- 			show_help = true,
	-- 			plugins = { spelling = true },
	-- 			replace = {
	-- 				key = {
	-- 					{ "<leader>", "SPC" },
	-- 				},
	-- 			},
	-- 			triggers = {
	-- 				{ "<leader>", mode = { "n", "v" } },
	-- 			},
	-- 			presets = {
	-- 				operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
	-- 				motions = true, -- adds help for motions
	-- 				text_objects = true, -- help for text objects triggered after entering an operator
	-- 				windows = true, -- default bindings on <c-w>
	-- 				nav = true, -- misc bindings to work with windows
	-- 				z = true, -- bindings for folds, spelling and others prefixed with z
	-- 				g = true, -- bindings for prefixed with g
	-- 			},
	-- 			icons = {
	-- 				breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
	-- 				separator = "➜", -- symbol used between a key and it's label
	-- 				group = "+", -- symbol prepended to a group
	-- 			},
	-- 			keys = {
	-- 				scroll_down = "<c-d>", -- binding to scroll down inside the popup
	-- 				scroll_up = "<c-u>", -- binding to scroll up inside the popup
	-- 			},
	-- 			win = {
	-- 				border = "single", -- none, single, double, shadow
	-- 				position = "bottom", -- bottom, top
	-- 				margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
	-- 				padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
	-- 				winblend = 0,
	-- 			},
	-- 			layout = {
	-- 				height = { min = 4, max = 25 }, -- min and max height of the columns
	-- 				width = { min = 20, max = 50 }, -- min and max width of the columns
	-- 				spacing = 3, -- spacing between columns
	-- 				align = "left", -- align columns left, center or right
	-- 			},
	-- 		})
	-- 		wk.register({
	-- 			-- mode = { "n", "v" },
	-- 			-- { "<leader>c", group = "Code" },
	-- 			-- { "<leader>cX", group = "Swap Previous" },
	-- 			-- { "<leader>cXc", desc = "Class" },
	-- 			-- { "<leader>cXf", desc = "Function" },
	-- 			-- { "<leader>cXp", desc = "Parameter" },
	-- 			-- { "<leader>cg", group = "Annotation" },
	-- 			-- { "<leader>cx", group = "Swap Next" },
	-- 			-- { "<leader>cxc", desc = "Class" },
	-- 			-- { "<leader>cxf", desc = "Function" },
	-- 			-- { "<leader>cxp", desc = "Parameter" },
	-- 			-- { "<leader>d", group = "Debug" },
	-- 			{ "<leader>f", group = "File" },
	-- 			-- { "<leader>g", group = "Git" },
	-- 			-- { "<leader>gh", group = "Hunk" },
	-- 			-- { "<leader>gt", group = "Toggle" },
	-- 			-- { "<leader>h", group = "Help" },
	-- 			-- { "<leader>j", group = "Jump" },
	-- 			-- { "<leader>n", group = "Notes" },
	-- 			-- { "<leader>p", group = "Project" },
	-- 			-- { "<leader>q", group = "Quit" },
	-- 			-- { "<leader>qa", desc = "Close all buffers" },
	-- 			-- { "<leader>qb", desc = "Close Buffer" },
	-- 			-- { "<leader>qq", desc = "Quit" },
	-- 			{ "<leader>qt", "<cmd>tabclose<cr>", desc = "Close Tab" },
	-- 			-- { "<leader>s", group = "Search" },
	-- 			-- { "<leader>t", group = "Test" },
	-- 			-- { "<leader>tN", group = "Neotest" },
	-- 			-- { "<leader>to", desc = "Overseer" },
	-- 			-- { "<leader>v", group = "View" },
	-- 			-- { "<leader>w", group = "Workspace" },
	-- 			{ "<leader>z", group = "System" },
	-- 		})
	-- 	end,
	-- },
}
