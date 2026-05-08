return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<M-l>",
						accept_word = "<M-w>",
						accept_line = "<M-j>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
				panel = { enabled = false }, -- you have CLI for chat-style exploration
				-- nes = { enabled = true, auto_trigger = true },
			})
		end,
	},
}
