return {
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
			diagnostics = {
				globals = { "vim" },
				disable = { "missing-fields" },
			},
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}
