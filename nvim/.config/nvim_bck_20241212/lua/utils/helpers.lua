local M = {}

function M.buffer_map(bufnr, mode, lhs, rhs, desc)
	if desc then
		desc = desc
	end
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
end

return M
