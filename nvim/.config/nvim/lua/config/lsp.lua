-- Global capabilities: base + nvim-cmp additions applied to every server.
vim.lsp.config("*", {
	capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("cmp_nvim_lsp").default_capabilities()
	),
})

-- Activate servers; per-server overrides are auto-loaded from lsp/<name>.lua
vim.lsp.enable({ "lua_ls", "ruff", "ty" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("pde-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		local t = require("telescope.builtin")
		map("gd", t.lsp_definitions, "[G]oto [D]efinition")
		map("gr", t.lsp_references, "[G]oto [R]eferences")
		map("gI", t.lsp_implementations, "[G]oto [I]mplementation")
		map("<leader>D", t.lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", t.lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", t.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
			local hl = vim.api.nvim_create_augroup("pde-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = hl,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = hl,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("pde-lsp-detach", { clear = true }),
				callback = function(e2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "pde-lsp-highlight", buffer = e2.buf })
				end,
			})
		end

		if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end

		-- Ruff has no hover; defer to ty.
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end
	end,
})
