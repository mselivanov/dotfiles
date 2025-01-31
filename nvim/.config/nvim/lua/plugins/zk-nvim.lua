return {
	"zk-org/zk-nvim",
	config = function()
		require("zk").setup({
			picker = "telescope",

			lsp = {
				-- `config` is passed to `vim.lsp.start_client(config)`
				config = {
					cmd = { "zk", "lsp" },
					name = "zk",
				},

				-- automatically attach buffers in a zk notebook that match the given filetypes
				auto_attach = {
					enabled = true,
					filetypes = { "markdown" },
				},
			},
		})
		local opts = { noremap = true, silent = false }
		opts.desc = " new [d]aily note"
		vim.api.nvim_set_keymap("n", "<leader>zd", "<Cmd>ZkNew { dir='journal/day'}<CR>", opts)
		opts.desc = "[t]ags"
		vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)
		opts.desc = "[n]otes"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>zn",
			"<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>",
			opts
		)
	end,
}
