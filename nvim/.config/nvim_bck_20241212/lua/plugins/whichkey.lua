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
			{ "<leader>a", group = "appearance" },
			{
				"<leader>at",
				function()
					require("telescope.builtin").colorscheme({ enable_preview = true })
				end,
				desc = "Colorscheme",
			},
			{ "<leader>c", group = "code" },
			{
				"<leader>cd",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Document Diagnostics",
			},
			{ "<leader>cw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>co", "<cmd>Telescope aerial<cr>", desc = "Code Outline" },
			{ "<leader>f", group = "find" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
			{ "<leader>ff", require("utils").find_files, desc = "Find Files" },
			{
				"<leader>fg",
				"<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>",
				desc = "Live grep",
			},
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
			{ "<leader>fp", "<cmd>Telescope lazy<cr>", desc = "Find Plugins" },
			{ "<leader>F", group = "files" },
			{ "<leader>Fr", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
			{ "<leader>Fe", "<cmd>NvimTreeToggle<cr>", desc = "File Tree" },
			{ "<leader>p", group = "projects" },
			{
				"<leader>pl",
				function()
					require("telescope").extensions.project.project({ display_type = "minimal" })
				end,
				desc = "List Projects",
			},
		},
	},
}
