return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",

		config = function()
			require("toggleterm").setup({
				start_in_insert = true,
				direction = "float",
				float_opts = {
					border = "double",
					title_pos = "left",
				},
			})

			local opts = { noremap = true, silent = false }
			opts.desc = "[t]erminal"
			vim.api.nvim_set_keymap("n", "<C-\\>", "<Cmd>ToggleTerm<CR>", opts)
			vim.api.nvim_set_keymap("t", "<C-\\>", "<Cmd>ToggleTerm<CR>", opts)
		end,
	},
}
