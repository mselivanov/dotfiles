vim.g.mapleader = ' '
-- Copy to clipboard
vim.keymap.set({'n', 'x'}, 'cp', '"+y')
-- Paste from clipboard
vim.keymap.set({'n', 'x'}, 'cv', '"+p')
