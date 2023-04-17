local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
  use { "wbthomason/packer.nvim", branch = "master"} -- Have packer manage itself
  use { "nvim-lua/plenary.nvim", branch = "master" } -- Useful lua functions used by lots of plugins
  use { "windwp/nvim-autopairs", branch = "master" } -- Autopairs, integrates with both cmp and treesitter
  use { "numToStr/Comment.nvim", branch = "master" }
  use { "JoosepAlviste/nvim-ts-context-commentstring", branch = "main" }
  use { "kyazdani42/nvim-web-devicons", branch = "master" }
  use { "kyazdani42/nvim-tree.lua", branch = "master" }
  use { "akinsho/bufferline.nvim", branch = "main" }
	use { "moll/vim-bbye", branch = "master" }
  use { "nvim-lualine/lualine.nvim", branch = "master" }
  use { "akinsho/toggleterm.nvim", branch = "main" }
  use { "ahmedkhalf/project.nvim", branch = "main" }
  use { "lewis6991/impatient.nvim", branch = "main" }
  use { "lukas-reineke/indent-blankline.nvim", branch = "master" }
  use { "goolord/alpha-nvim", branch = "main" }
	use {"folke/which-key.nvim"}
	use {"tpope/vim-surround", branch="master"}
	use {"wellle/targets.vim", branch="master"}

	-- Colorschemes
  use { "folke/tokyonight.nvim", branch = "main" }
  use { "lunarvim/darkplus.nvim", branch = "master" }
  use { "shaunsingh/nord.nvim"}

	-- Cmp 
  use { "hrsh7th/nvim-cmp", branch = "main" } -- The completion plugin
  use { "hrsh7th/cmp-buffer", branch = "main" } -- buffer completions
  use { "hrsh7th/cmp-path", branch = "main" } -- path completions
	use { "saadparwaiz1/cmp_luasnip", branch = "master" } -- snippet completions
	use { "hrsh7th/cmp-nvim-lsp", branch = "main" }
	use { "hrsh7th/cmp-nvim-lua", branch = "main" }

	-- Snippets
  use { "L3MON4D3/LuaSnip", branch = "master" } --snippet engine
  use { "rafamadriz/friendly-snippets", branch = "main" } -- a bunch of snippets to use

	-- LSP
	use { "neovim/nvim-lspconfig", branch = "master" } -- enable LSP
  use { "williamboman/mason.nvim", branch = "main" } -- simple to use language server installer
  use { "williamboman/mason-lspconfig.nvim", branch = "main" }
	use { "jose-elias-alvarez/null-ls.nvim", branch = "main" } -- for formatters and linters
  use { "RRethy/vim-illuminate", branch = "master" }
  use { "nanotee/sqls.nvim", branch = "main" }
  use { "lukas-reineke/lsp-format.nvim", branch = "master" }

	-- Telescope
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
	use {"nvim-telescope/telescope.nvim", branch = "master" }
  use {"nvim-telescope/telescope-live-grep-args.nvim", branch="master"}
  use {"kiyoon/telescope-insert-path.nvim", branch="master"}

	-- Treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
	}

	-- Git
	use { "lewis6991/gitsigns.nvim",  branch = "main"}
	use { "tpope/vim-fugitive",  branch = "master"}
	use { "junegunn/gv.vim",  branch = "master"}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
