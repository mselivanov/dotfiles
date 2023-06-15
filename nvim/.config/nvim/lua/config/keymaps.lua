local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
-- local keymap = vim.api.nvim_set_keymap
local keymap = vim.keymap.set

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

--
-- Remap for dealing with word wrap
keymap("n", "<leader>ww", "<cmd>bufdo update!<CR>", { desc = "Save workspace" })
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Better viewing
keymap("n", "n", "nzzzv", { desc = "Next search match and center screen" })
keymap("n", "N", "Nzzzv", { desc = "Previous search match and center screen" })
keymap("n", "g,", "g,zvzz", { desc = "Next item in changelist and center screen" })
keymap("n", "g;", "g;zvzz", { desc = "Previous in changelist and center screen" })

-- Scrolling
keymap("n", "<C-d>", "<C-d>zz", { desc = "Paste below" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Paste below" })

-- Paste
keymap("n", "]p", "o<Esc>p", { desc = "Paste below" })
keymap("n", "]P", "O<Esc>p", { desc = "Paste above" })

-- Insert blank line
keymap("n", "]<Space>", "o<Esc>", { desc = "Paste below" })
keymap("n", "[<Space>", "O<Esc>", { desc = "Paste below" })

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with Alt
keymap("n", "<A-j>", ":resize +2<CR>", opts)
keymap("n", "<A-k>", ":resize -2<CR>", opts)
keymap("n", "<A-h>", ":vertical resize -2<CR>", opts)
keymap("n", "<A-l>", ":vertical resize +2<CR>", opts)

-- Buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>qb", ":bdel!<CR>", opts)

-- Insert --
-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Auto indent
keymap("n", "i", function()
	if #vim.fn.getline(".") == 0 then
		return [["_cc]]
	else
		return "i"
	end
end, { expr = true })

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Command mode --
keymap("c", "<C-b>", "<Left>", opts)
keymap("c", "<C-f>", "<Right>", opts)

-- Clipboard operations --
-- Copy and paste text to/from clipboard
keymap("v", "cc", '"*y', opts)
keymap("x", "cc", '"*y', opts)
keymap("n", "cv", '"*p', opts)

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dp')

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- SQL find and replace
keymap("v", "<leader>rp", ":s/[.:]/_/g<CR>:nohl<CR>", opts)
keymap("v", "<leader>rd", ":s/\\(\\s*\\)\\(\\S\\+\\)\\(.\\{-}\\)\\(,\\?$\\)/\\1\\2\\4/g<CR>:nohl<CR>", opts)
-- Generate SQL MERGE UPDATE part from columns list
keymap(
	"v",
	"<leader>mu",
	':s/\\(\\s*\\)\\("\\?\\w\\+"\\?\\)\\(,\\?\\)\\(\\s\\+\\)\\($\\)/\\1tgt.\\2 = src.\\2\\3\\5/g<CR>:nohl<CR>',
	opts
)
-- Generate SQL MERGE VALUES part from columns list
keymap(
	"v",
	"<leader>mv",
	':s/\\(\\s*\\)\\("\\?\\w\\+"\\?\\)\\(,\\?\\)\\(\\s\\+\\)\\($\\)/\\1src.\\2\\3\\5/g<CR>:nohl<CR>',
	opts
)
