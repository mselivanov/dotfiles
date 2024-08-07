return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-file-browser.nvim",
			"nvim-telescope/telescope-project.nvim",
			"stevearc/aerial.nvim",
			"aaronhallaert/advanced-git-search.nvim",
			"benfowler/telescope-luasnip.nvim",
			"olacin/telescope-cc.nvim",
			"tsakirist/telescope-lazy.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		cmd = "Telescope",
    -- stylua: ignore
    keys = {
      { "<leader><space>", require("utils").find_files, desc = "Find Files" },
      { "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
      { "<leader>sb", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Buffer", },
    },
		config = function(_, _)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local actions_layout = require("telescope.actions.layout")
			local transform_mod = require("telescope.actions.mt").transform_mod
			local custom_actions = transform_mod({
				-- VisiData
				visidata = function(prompt_bufnr)
					-- Get the full path
					local content = require("telescope.actions.state").get_selected_entry()
					if content == nil then
						return
					end
					local full_path = content.cwd .. require("plenary.path").path.sep .. content.value

					-- Close the Telescope window
					require("telescope.actions").close(prompt_bufnr)

					-- Open the file with VisiData
					local utils = require("utils")
					utils.open_term("vd " .. full_path, { direction = "float" })
				end,

				-- File browser
				file_browser = function(prompt_bufnr)
					local content = require("telescope.actions.state").get_selected_entry()
					if content == nil then
						return
					end

					local full_path = content.cwd
					if content.filename then
						full_path = content.filename
					elseif content.value then
						full_path = full_path .. require("plenary.path").path.sep .. content.value
					end

					-- Close the Telescope window
					require("telescope.actions").close(prompt_bufnr)

					-- Open file browser
					-- vim.cmd("Telescope file_browser select_buffer=true path=" .. vim.fs.dirname(full_path))
					require("telescope").extensions.file_browser.file_browser({
						select_buffer = true,
						path = vim.fs.dirname(full_path),
					})
				end,
			})

			local mappings = {
				i = {
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<C-n>"] = actions.cycle_history_next,
					["<C-p>"] = actions.cycle_history_prev,
					["?"] = actions_layout.toggle_preview,
					["<C-s>"] = custom_actions.visidata,
					["<A-f>"] = custom_actions.file_browser,
				},
				n = {
					["s"] = custom_actions.visidata,
					["<A-f>"] = custom_actions.file_browser,
				},
			}

			local vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
			}

			local opts = {
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					mappings = mappings,
					border = {},
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					color_devicons = true,
					vimgrep_arguments = vimgrep_arguments,
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						previewer = false,
						hidden = true,
						find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
					},
					git_files = {
						theme = "dropdown",
						previewer = false,
					},
					buffers = {
						theme = "dropdown",
						previewer = false,
					},
				},
				extensions = {
					file_browser = {
						theme = "dropdown",
						previewer = false,
						hijack_netrw = true,
						mappings = mappings,
					},
					project = {
						hidden_files = false,
						theme = "dropdown",
						base_dirs = {
							"~",
						},
						hidden_files = true,
						order_by = "asc",
						search_by = "title",
						sync_with_nvim_tree = true,
						on_project_selected = function(prompt_bufnr)
							local project_actions = require("telescope._extensions.project.actions")
							project_actions.change_working_directory(prompt_bufnr)
						end,
					},
				},
			}
			telescope.setup(opts)
			telescope.load_extension("fzf")
			telescope.load_extension("file_browser")
			telescope.load_extension("project")
			telescope.load_extension("aerial")
			telescope.load_extension("luasnip")
			telescope.load_extension("conventional_commits")
			telescope.load_extension("lazy")
			telescope.load_extension("live_grep_args")
		end,
	},
	{
		"stevearc/aerial.nvim",
		config = true,
	},
}
