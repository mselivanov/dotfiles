-----------------------------------------------
-- Editing settings
-----------------------------------------------
-- Copy to clipboard
vim.keymap.set({'n', 'x'}, 'cc', '"+y')
-- Paste from clipboard
vim.keymap.set({'n', 'x'}, 'cv', '"+p')

-----------------------------------------------
-- Tab settings
-----------------------------------------------
vim.keymap.set({'n'}, '<C-t>', ':tabnew<CR>')
vim.keymap.set({'n'}, '<C-F4>', ':tabnew<CR>')
vim.keymap.set({'n'}, '<C-F4>', ':tabclose<CR>')
vim.keymap.set({'n'}, '<A-l>', ':tabnext<CR>')
vim.keymap.set({'n'}, '<A-h>', ':tabprev<CR>')

-----------------------------------------------
-- Window settings
-----------------------------------------------
vim.keymap.set({'n'}, '<C-N>', '<C-W>v')
vim.keymap.set({'n'}, '<C-J>', '<C-W>j')
vim.keymap.set({'n'}, '<C-K>', '<C-W>k')
vim.keymap.set({'n'}, '<C-H>', '<C-W>h')
vim.keymap.set({'n'}, '<C-L>', '<C-W>l')
