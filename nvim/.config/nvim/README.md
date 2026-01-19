# Neovim Configuration Analysis & Recommendations

**Configuration Type:** Personal Development Environment
**Target Use Case:** Data Engineering
**Primary Languages:** Python, SQL, PowerShell, Bash, Databricks, Just
**Analysis Date:** 2026-01-01

---

## Current Configuration Overview

### Strengths

1. **Solid Foundation**
   - Modern plugin manager (lazy.nvim) with good lazy-loading strategy
   - Comprehensive LSP setup with Mason for automatic tool installation
   - Well-organized modular structure (config/, plugins/)
   - Treesitter for advanced syntax highlighting and code navigation
   - Effective fuzzy finding with Telescope + fzf-native

2. **Python Development**
   - Pyright LSP with Ruff integration for type checking
   - Auto-formatting with isort + black via conform.nvim
   - Good completion setup with nvim-cmp
   - Proper Python treesitter support

3. **SQL Workflow Support**
   - Custom keymaps for SQL text manipulation (lines 123-140 in keymaps.lua)
   - Specialized MERGE statement generation macros
   - Column list transformation utilities

4. **General Development**
   - Git integration (gitsigns.nvim)
   - Terminal integration (toggleterm.nvim)
   - Just task runner syntax support (vim-just, tree-sitter-just)
   - Smart features (autopairs, surround, todo-comments)

### Current Gaps for Data Engineering

1. **Missing Language Support**
   - No PowerShell LSP or syntax highlighting
   - Limited SQL tooling (no LSP, no query execution)
   - No Databricks-specific integrations

2. **Missing Data Engineering Tools**
   - No database connection/query runners
   - No notebook support (critical for Databricks)
   - No data preview/visualization capabilities
   - No REPL integration for interactive development
   - No CSV/JSON/Parquet file viewers

3. **Python Tooling Gaps**
   - Using older formatters (black/isort) instead of consolidated Ruff
   - No dedicated testing framework integration
   - No virtual environment indicator in statusline
   - No debugger setup (DAP)

4. **Workflow Optimization**
   - No project-specific configurations
   - Limited snippet library for common data engineering patterns
   - No Jinja2/template support (common in dbt/Airflow)

---

## Recommended Improvements

### Priority 1: Essential Language Support

#### 1.1 SQL Enhancement

**Add SQL LSP and Formatters:**
```lua
-- In lua/plugins/init.lua, add to servers table:
servers = {
  sqlls = {},  -- SQL Language Server
  -- ... existing servers
}

-- In ensure_installed:
vim.list_extend(ensure_installed, {
  "sqlls",
  "sqlfmt",      -- SQL formatter
  "sqlfluff",    -- SQL linter
})

-- Update formatters_by_ft in conform.nvim:
formatters_by_ft = {
  sql = { "sqlfluff", "sqlfmt" },
  -- ... existing formatters
}
```

**Add Database Plugin for Query Execution:**
```lua
-- Create lua/plugins/dadbod.lua
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_win_position = "right"
    end,
    keys = {
      { "<leader>Fd", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
    },
  },
}
```

**Benefits:** Execute SQL directly from Neovim, manage multiple database connections, autocomplete table/column names

#### 1.2 PowerShell Support

```lua
-- Add to lua/plugins/init.lua
-- In servers table:
servers = {
  powershell_es = {
    bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
  },
  -- ... existing servers
}

-- Add to treesitter ensure_installed:
ensure_installed = {
  "powershell",
  -- ... existing parsers
}
```

#### 1.3 Python Optimization - Switch to Ruff

**Update conform.nvim configuration:**
```lua
-- Replace black + isort with ruff
formatters_by_ft = {
  python = { "ruff_format", "ruff_organize_imports" },
  -- ... other formatters
}

-- Add to ensure_installed:
vim.list_extend(ensure_installed, {
  "ruff",  -- Replaces black, isort, flake8, pylint
})
```

**Add Ruff LSP alongside Pyright:**
```lua
servers = {
  ruff_lsp = {},
  pyright = {
    -- ... existing pyright config
  },
}
```

**Benefits:** Faster linting/formatting (10-100x), single tool instead of multiple, modern Python best practices

### Priority 2: Data Engineering Workflow

#### 2.1 Notebook Support for Databricks

```lua
-- Create lua/plugins/notebook.lua
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_virt_text_output = true
    end,
    keys = {
      { "<leader>mi", ":MoltenInit<CR>", desc = "Initialize Molten" },
      { "<leader>me", ":MoltenEvaluateOperator<CR>", desc = "Evaluate operator", mode = "n" },
      { "<leader>ml", ":MoltenEvaluateLine<CR>", desc = "Evaluate line" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Re-evaluate cell" },
      { "<leader>mc", ":MoltenEvaluateVisual<CR>", desc = "Evaluate visual", mode = "v" },
      { "<leader>md", ":MoltenDelete<CR>", desc = "Delete Molten cell" },
    },
  },
  {
    -- Image support for notebook outputs
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- or "ueberzug" depending on terminal
      integrations = {
        markdown = { enabled = true },
      },
    },
  },
}
```

**Alternative for .ipynb files:**
```lua
return {
  "GCBallesteros/jupytext.nvim",
  config = function()
    require("jupytext").setup({
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    })
  end,
}
```

#### 2.2 CSV/Data File Viewer

```lua
-- Create lua/plugins/csv.lua
return {
  {
    "chrisbra/csv.vim",
    ft = { "csv", "tsv" },
    config = function()
      vim.g.csv_arrange_align = "l*"
      vim.g.csv_autocmd_arrange = 1
      vim.g.csv_delim_test = ",;\t|"
    end,
  },
}
```

#### 2.3 REPL Integration

```lua
-- Create lua/plugins/repl.lua
return {
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = { "ipython" },
              format = require("iron.fts.common").bracketed_paste,
            },
            sh = {
              command = { "bash" },
            },
          },
          repl_open_cmd = require("iron.view").split.vertical.botright(80),
        },
        keymaps = {
          send_motion = "<leader>sc",
          visual_send = "<leader>sc",
          send_file = "<leader>sf",
          send_line = "<leader>sl",
          send_until_cursor = "<leader>su",
          send_mark = "<leader>sm",
          cr = "<leader>s<cr>",
          interrupt = "<leader>s<space>",
          exit = "<leader>sq",
          clear = "<leader>sr",
        },
      })
    end,
    keys = {
      { "<leader>rs", "<cmd>IronRepl<cr>", desc = "Start REPL" },
      { "<leader>rr", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
    },
  },
}
```

### Priority 3: Enhanced Developer Experience

#### 3.1 Debugging Support (DAP)

```lua
-- Create lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Python debugger
      require("dap-python").setup("python")  -- or "~/.virtualenvs/debugpy/bin/python"

      -- Auto-open UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue" },
      { "<leader>di", "<cmd>DapStepInto<cr>", desc = "Step Into" },
      { "<leader>do", "<cmd>DapStepOver<cr>", desc = "Step Over" },
      { "<leader>dO", "<cmd>DapStepOut<cr>", desc = "Step Out" },
      { "<leader>dt", "<cmd>DapTerminate<cr>", desc = "Terminate" },
    },
  },
}
```

**Add to ensure_installed:**
```lua
vim.list_extend(ensure_installed, {
  "debugpy",  -- Python debugger
})
```

#### 3.2 Testing Framework Integration

```lua
-- Create lua/plugins/testing.lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG", "-vv" },
            runner = "pytest",
          }),
        },
      })
    end,
    keys = {
      { "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
      { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run file tests" },
      { "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug test" },
      { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Test summary" },
      { "<leader>to", "<cmd>lua require('neotest').output_panel.toggle()<cr>", desc = "Test output" },
    },
  },
}
```

#### 3.3 Enhanced Python Snippets

```lua
-- Update lua/plugins/init.lua LuaSnip config:
dependencies = {
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
```

**Create custom snippets file at `snippets/python.json`:**
```json
{
  "Pandas Read CSV": {
    "prefix": "pdread",
    "body": [
      "df = pd.read_csv('$1', ${2:sep=','}${3:, encoding='utf-8'})",
      "$0"
    ]
  },
  "Spark DataFrame": {
    "prefix": "sparkdf",
    "body": [
      "df = spark.read.format('${1:parquet}').load('$2')",
      "$0"
    ]
  },
  "SQL Query": {
    "prefix": "sqlquery",
    "body": [
      "query = \"\"\"",
      "SELECT $1",
      "FROM $2",
      "WHERE $3",
      "\"\"\"",
      "df = spark.sql(query)",
      "$0"
    ]
  },
  "Databricks Display": {
    "prefix": "display",
    "body": [
      "display(${1:df})",
      "$0"
    ]
  }
}
```

#### 3.4 Virtual Environment Display

**Update lua/plugins/init.lua mini.statusline section:**
```lua
-- Add virtual environment to statusline
local function venv()
  local venv_name = os.getenv("VIRTUAL_ENV")
  if venv_name then
    return " " .. vim.fn.fnamemodify(venv_name, ":t")
  end
  return ""
end

statusline.section_location = function()
  return venv() .. " %2l:%-2v"
end
```

#### 3.5 Project-Specific Configuration

```lua
-- Create lua/plugins/project.lua
return {
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "pyproject.toml", "setup.py", "requirements.txt", "Makefile", "justfile" },
        show_hidden = true,
      })
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find Projects" },
    },
  },
}
```

### Priority 4: Additional Enhancements

#### 4.1 Template/Jinja2 Support

```lua
-- Add to treesitter ensure_installed:
ensure_installed = {
  "jinja",
  "htmldjango",  -- Also supports Jinja2
  -- ... existing parsers
}
```

#### 4.2 YAML/TOML Enhancements (for configs)

```lua
-- Add to servers:
servers = {
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
        },
      },
    },
  },
  taplo = {},  -- TOML LSP
  -- ... existing servers
}

-- Add to treesitter:
ensure_installed = {
  "yaml",
  "toml",
  "json",
  "jsonc",
  -- ... existing parsers
}
```

#### 4.3 Better Git Integration

```lua
-- Create lua/plugins/git.lua
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Commit" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
    },
  },
}
```

#### 4.4 JSON/YAML Viewer for Data Files

```lua
-- Add jq for JSON manipulation
-- In ensure_installed:
vim.list_extend(ensure_installed, {
  "jq",  -- JSON processor
})

-- Add formatter:
formatters_by_ft = {
  json = { "jq" },
  yaml = { "yamlfmt" },
  -- ... existing formatters
}
```

---

## Keybinding Reference for Data Engineering

### Recommended Additional Keymaps

**Add to lua/config/keymaps.lua:**

```lua
-- Database operations
opts.desc = "Run SQL query"
keymap("v", "<leader>sq", "<cmd>DBExecVisual<CR>", opts)

-- Python specific
opts.desc = "Run Python file"
keymap("n", "<leader>pr", "<cmd>!python %<CR>", opts)

opts.desc = "Format imports"
keymap("n", "<leader>pi", "<cmd>!ruff check --select I --fix %<CR>", opts)

-- Data preview
opts.desc = "Preview CSV"
keymap("n", "<leader>pc", "<cmd>CSVTable<CR>", opts)

-- Notebook operations (if using molten)
opts.desc = "Run cell"
keymap("n", "<leader>nr", "<cmd>MoltenEvaluateOperator<CR>", opts)

opts.desc = "Add cell below"
keymap("n", "<leader>na", "o# %%<CR><CR>", opts)
```

### Current Keymap Strengths

Your existing SQL manipulation keymaps are excellent:
- `<leader>rp` - Replace dots/colons with underscores
- `<leader>rd` - Remove data types from column definitions
- `<leader>mu` - Generate MERGE UPDATE statements
- `<leader>mv` - Generate MERGE VALUES statements

These are practical time-savers for data engineering work.

---

## Configuration Priority Matrix

| Priority | Category | Impact | Effort | Recommendation |
|----------|----------|--------|--------|----------------|
| 1 | Ruff LSP/Formatter | High | Low | Immediate |
| 1 | SQL LSP (sqlls) | High | Low | Immediate |
| 1 | PowerShell Support | High | Low | Immediate |
| 2 | Database UI (dadbod) | High | Medium | Week 1 |
| 2 | CSV Viewer | Medium | Low | Week 1 |
| 2 | REPL Integration | High | Medium | Week 2 |
| 3 | DAP (Debugger) | High | Medium | Week 2 |
| 3 | Testing (neotest) | Medium | Medium | Week 3 |
| 3 | Notebook Support | Medium | High | Week 3-4 |
| 4 | Project Management | Low | Low | Optional |
| 4 | Enhanced Git UI | Low | Low | Optional |

---

## Installation Instructions

### Quick Start - Priority 1 Items

1. **Update Python tooling to Ruff:**
   ```bash
   # In Neovim
   :MasonInstall ruff ruff-lsp
   ```

2. **Add SQL support:**
   ```bash
   :MasonInstall sqlls sqlfmt sqlfluff
   ```

3. **Add PowerShell:**
   ```bash
   :MasonInstall powershell-editor-services
   ```

4. **Update treesitter parsers:**
   ```vim
   :TSInstall powershell sql jinja yaml toml json
   ```

### System Dependencies

Some plugins require external tools:

```bash
# For notebook support (molten)
pip install pynvim jupyter_client cairosvg plotly kaleido

# For REPL
pip install ipython

# For debugging
pip install debugpy

# For testing
pip install pytest pytest-cov

# For database connections
# Install relevant database drivers (psycopg2, pymysql, etc.)
```

---

## Performance Considerations

1. **Lazy Loading:** Your current setup already uses good lazy-loading practices. Continue this pattern for new plugins.

2. **Startup Time:** With recommended additions, expect ~50-100ms increase in startup time (still under 200ms total).

3. **Memory Usage:** Database UI and notebook support will increase memory usage by ~50-100MB when active.

4. **LSP Performance:** Running both Pyright and Ruff LSP is recommended - they complement each other (types vs linting).

---

## Next Steps

1. **Immediate Actions:**
   - Switch Python formatting from black/isort to Ruff
   - Add SQL LSP and formatters
   - Add PowerShell support

2. **This Week:**
   - Install and configure vim-dadbod for database work
   - Add CSV viewer for data file inspection
   - Set up custom Python snippets for common patterns

3. **This Month:**
   - Configure debugging with nvim-dap
   - Set up testing framework integration
   - Explore notebook support based on workflow needs

4. **Optional Enhancements:**
   - Consider switching to lualine for more powerful statusline
   - Add REST client plugin for API testing (rest.nvim)
   - Explore Databricks CLI integration

---

## Additional Resources

- **SQL in Neovim:** https://github.com/tpope/vim-dadbod
- **Python DAP Setup:** https://github.com/mfussenegger/nvim-dap-python
- **Databricks Best Practices:** Consider using Databricks Connect with local development
- **Just Task Runner:** Your current vim-just setup is optimal

---

## Conclusion

Your current Neovim configuration provides a solid foundation for data engineering work. The primary gaps are:

1. Modernizing Python tooling (Ruff)
2. Enhancing SQL capabilities (LSP + database UI)
3. Adding PowerShell support
4. Implementing debugging and testing workflows
5. Optional: Notebook integration for Databricks work

The modular structure makes it easy to add these enhancements incrementally. Start with Priority 1 items (low effort, high impact) and expand based on your specific workflow needs.

**Configuration Health:** 7/10
**Data Engineering Readiness:** 6/10 (with recommendations: 9/10)
