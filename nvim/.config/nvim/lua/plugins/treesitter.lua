local parsers = {
	"bash",
	"diff",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"vim",
	"vimdoc",
}

-- Filetypes that map to those parsers and need treesitter features enabled.
-- (lua / markdown / query / help already get highlight from Neovim's shipped ftplugins,
--  but we re-enable here for folds + indent consistency across the full list.)
local filetypes = {
	"bash",
	"sh",
	"zsh",
	"diff",
	"lua",
	"markdown",
	"python",
	"query",
	"vim",
	"help",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"nvim-treesitter/nvim-treesitter-locals",
	},
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		if vim.fn.executable("tree-sitter") == 1 then
			require("nvim-treesitter").install(parsers)
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("pde-treesitter", { clear = true }),
			pattern = filetypes,
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
				vim.wo[0][0].foldmethod = "expr"
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
