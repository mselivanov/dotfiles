---------------------------------------------
-- Coc plugin keymap
---------------------------------------------
vim.cmd([[
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>
" use <c-space>for trigger completion

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
]])

---------------------------------------------
-- Fzf plugin keymap
---------------------------------------------
vim.api.nvim_set_keymap('n', '<C-P>',
    "<cmd>lua require('fzf-lua').files()<CR>",
    { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-S>',
    "<cmd>lua require('fzf-lua').grep()<CR>",
    { noremap = true, silent = true })
