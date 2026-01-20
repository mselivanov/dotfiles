# Neovim Configuration Review: Python, SQL, and Databricks Development

**Review Date**: 2026-01-20
**Configuration Location**: `nvim/.config/nvim/`
**Focus Areas**: Python, SQL, Databricks development workflows

## Executive Summary

The current Neovim configuration is well-structured with a modern plugin management setup using Lazy.nvim. You're already using cutting-edge Astral tooling (Ruff for linting/formatting and ty for type checking), but they're not yet configured as LSP servers. This review provides actionable recommendations to transform your setup into a powerful data engineering IDE by enabling the LSP capabilities of your existing tools and adding specialized SQL and Databricks integrations.

## Current State Analysis

### Strengths

1. **Modern Architecture**
   - Clean modular structure with separate config and plugin files
   - Lazy.nvim for efficient plugin management
   - LSP foundation with Mason for easy tool installation
   - Good keybinding organization with which-key

2. **Essential Tooling Present**
   - Treesitter for syntax highlighting (Python already included)
   - Telescope for fuzzy finding with live grep
   - nvim-cmp for autocompletion
   - Git integration via gitsigns
   - Terminal integration with toggleterm
   - Ruff for Python linting and formatting (via conform.nvim)
   - SQL formatting tools (sqlfmt, sqlfluff) already installed

3. **Custom SQL Utilities**
   - SQL MERGE statement generators in keymaps.lua:123-140
   - Custom keybindings for SQL transformations

### Gaps for Data Engineering

1. **Python Development**
   - Ruff is present for linting/formatting but not configured as LSP server
   - ty (Astral's type checker) is installed but not configured as LSP
   - Missing Python-specific debugging capabilities
   - No virtual environment management integration
   - No Jupyter notebook support
   - Missing Python test runner integration (pytest, unittest)
   - No code coverage visualization

2. **SQL Development**
   - No SQL LSP for intelligent autocompletion
   - Missing database connection/query execution plugins
   - No SQL dialect-specific support
   - Limited SQL formatting options
   - No query result visualization

3. **Databricks Integration**
   - No Databricks CLI integration
   - Missing notebook synchronization capabilities
   - No cluster management interface
   - No Databricks-specific SQL dialect support

4. **Data Engineering Workflows**
   - No CSV/Parquet file preview
   - Missing data validation tools
   - No schema visualization
   - Limited table/column navigation

## Detailed Recommendations

### 1. Python Development Enhancements

#### 1.1 Configure Ruff LSP + ty Type Checker (High Priority)

**Current State Analysis** (lines 224-284):

You have a subtle configuration issue:
```lua
local servers = {
    lua_ls = { ... },  -- Only Lua LSP is configured here
    -- ty and ruff are MISSING from this table
}

-- Later (line 277-284):
local ensure_installed = vim.tbl_keys(servers or {})  -- Gets: ["lua_ls"]
vim.list_extend(ensure_installed, {
    "stylua",
    "ruff",     -- ✓ Binary installed, but NOT configured as LSP
    "sqlfmt",
    "sqlfluff",
    "ty",       -- ✓ Binary installed, but NOT configured as LSP
})
```

**The Problem**:
- `servers` table = LSP server configurations (mason-lspconfig uses this)
- `ensure_installed` = Binaries to install (mason-tool-installer uses this)
- **ruff and ty are in ensure_installed but NOT in servers**, so they install but don't run as LSP servers!

**The Fix**: Add ty and ruff_lsp to the `servers` table

**File**: `nvim/.config/nvim/lua/plugins/init.lua:224`

Replace the servers table with:

```lua
local servers = {
    -- Python: Ruff LSP for linting, formatting, and code actions
    ruff_lsp = {
        init_options = {
            settings = {
                args = {
                    -- Optional: point to global config
                    -- "--config", vim.fn.expand("~/.ruff.toml"),
                },
            }
        }
    },

    -- Python: ty for blazing-fast type checking
    -- ty is Astral's new type checker (formerly Red-Knot)
    -- 10-60x faster than Pyright, with advanced type analysis
    ty = {
        settings = {
            ty = {
                -- Optional: point to project-specific config
                -- configurationFile = "./pyproject.toml",
            }
        }
    },

    -- Lua LSP (already present)
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = "Replace",
                },
                diagnostics = { globals = { "vim" } },
            },
        },
    },
}
```

**Update LSP attach handler** (line 191-194): Remove the hover disable since Ruff LSP now has good hover support

```lua
-- Remove or comment out lines 191-194:
-- if client and client.name == "ruff" then
--     client.server_capabilities.hoverProvider = false
-- end
```

**Update ensure_installed** (line 278-284):

The current code is slightly confusing. Improve it by adding comments:

```lua
-- Install LSP servers and standalone tools
local ensure_installed = vim.tbl_keys(servers or {})  -- Installs: lua_ls, ruff_lsp, ty
vim.list_extend(ensure_installed, {
    -- Formatters and linters (standalone tools, not LSPs)
    "stylua",    -- Lua formatter
    "sqlfmt",    -- SQL formatter
    "sqlfluff",  -- SQL linter

    -- Note: "ruff" binary is included with ruff_lsp
    -- Note: "ty" binary is included with ty LSP
})
```

**After this change**:
- ✅ ruff_lsp will be installed AND configured as an LSP
- ✅ ty will be installed AND configured as an LSP
- ✅ Code is clearer about what goes where

**Optional: Create ty configuration** in `pyproject.toml`:

```toml
[tool.ty]
# ty configuration options
# See: https://docs.astral.sh/ty/
```

**Rationale**:
- **Ruff LSP**: Blazing-fast linting and code actions
- **ty**: 10-60x faster type checking with advanced features
- **Complete Astral stack**: Unified tooling, all written in Rust
- **Clearer code**: Separates LSP configs from standalone tools

#### 1.2 Add Python Debugging (DAP)

**New File**: `nvim/.config/nvim/lua/plugins/dap.lua`

```lua
return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "mfussenegger/nvim-dap-python",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Setup DAP UI
            dapui.setup()

            -- Setup Python debugging
            require("dap-python").setup("python")  -- or path to debugpy

            -- Auto-open/close DAP UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end

            -- Keybindings
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug: Toggle [B]reakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug: [C]ontinue" })
            vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug: Step [I]nto" })
            vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[D]ebug: Step [O]ver" })
            vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[D]ebug: Open [R]EPL" })
        end,
    },
}
```

**Benefits**: Full debugging capabilities with breakpoints, variable inspection, and step-through execution.

#### 1.3 Virtual Environment Management

**New File**: `nvim/.config/nvim/lua/plugins/python-env.lua`

```lua
return {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim",
        },
        opts = {
            name = { "venv", ".venv", "env", ".env" },
            auto_refresh = true,
        },
        keys = {
            { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "[V]env [S]elect" },
            { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "[V]env Select [C]ached" },
        },
    },
}
```

**Benefits**: Seamless switching between virtual environments, automatic detection.

#### 1.4 Test Runner Integration

**New File**: `nvim/.config/nvim/lua/plugins/test.lua`

```lua
return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        args = { "--log-level", "DEBUG" },
                        runner = "pytest",  -- or "unittest"
                    }),
                },
            })

            -- Keybindings
            local neotest = require("neotest")
            vim.keymap.set("n", "<leader>tr", neotest.run.run, { desc = "[T]est [R]un" })
            vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "[T]est [F]ile" })
            vim.keymap.set("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "[T]est [D]ebug" })
            vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, { desc = "[T]est [S]ummary" })
            vim.keymap.set("n", "<leader>to", neotest.output.open, { desc = "[T]est [O]utput" })
        end,
    },
}
```

**Benefits**: Run and debug tests directly from Neovim, see results inline.

#### 1.5 Jupyter Notebook Support

**New File**: `nvim/.config/nvim/lua/plugins/jupyter.lua`

```lua
return {
    {
        "benlubas/molten-nvim",
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        config = function()
            vim.g.molten_auto_open_output = false
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_max_height = 20

            -- Keybindings
            vim.keymap.set("n", "<leader>ji", ":MoltenInit<CR>", { desc = "[J]upyter [I]nit", silent = true })
            vim.keymap.set("n", "<leader>je", ":MoltenEvaluateOperator<CR>", { desc = "[J]upyter [E]valuate", silent = true })
            vim.keymap.set("n", "<leader>jl", ":MoltenEvaluateLine<CR>", { desc = "[J]upyter Eval [L]ine", silent = true })
            vim.keymap.set("v", "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "[J]upyter Eval [V]isual", silent = true })
        end,
    },
    {
        "GCBallesteros/jupytext.nvim",
        config = true,
        -- Allows editing Jupyter notebooks as plain Python files
    },
}
```

**Benefits**: Run Jupyter cells directly in Neovim, avoid context switching.

### 2. SQL Development Enhancements

#### 2.1 Add SQL LSP

**Update**: `nvim/.config/nvim/lua/plugins/init.lua:264` (add to servers table)

```lua
sqlls = {
    cmd = { "sql-language-server", "up", "--method", "stdio" },
    filetypes = { "sql", "mysql" },
    root_dir = function() return vim.loop.cwd() end,
},
```

**Update**: `nvim/.config/nvim/lua/plugins/init.lua:278` (add to ensure_installed)

```lua
vim.list_extend(ensure_installed, {
    "stylua",
    "ruff",
    "sqlfmt",
    "sqlfluff",
    "sql-language-server",  -- Add this
    "ty",
})
```

**Benefits**: Intelligent SQL completion, syntax checking, and navigation.

#### 2.2 Database Client Integration

**New File**: `nvim/.config/nvim/lua/plugins/database.lua`

```lua
return {
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            "tpope/vim-dadbod",
            "kristijanhusak/vim-dadbod-completion",
        },
        config = function()
            -- Database connections stored in g:dbs
            -- Example: vim.g.dbs = { dev = "postgresql://localhost/mydb" }

            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
            vim.g.db_ui_force_echo_notifications = 1
            vim.g.db_ui_win_position = "right"
            vim.g.db_ui_winwidth = 40

            -- Save query results to file
            vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")

            -- Keybindings
            vim.keymap.set("n", "<leader>Du", ":DBUIToggle<CR>", { desc = "[D]B [U]I Toggle" })
            vim.keymap.set("n", "<leader>Df", ":DBUIFindBuffer<CR>", { desc = "[D]B [F]ind Buffer" })
            vim.keymap.set("n", "<leader>Dr", ":DBUIRenameBuffer<CR>", { desc = "[D]B [R]ename Buffer" })
            vim.keymap.set("n", "<leader>Dq", ":DBUILastQueryInfo<CR>", { desc = "[D]B Last [Q]uery" })
        end,
    },
}
```

**Configuration**: Add to `~/.config/nvim/local.lua` (not tracked in git)

```lua
-- Database connections (machine-specific)
vim.g.dbs = {
    dev = "postgresql://user:password@localhost/dev_db",
    staging = "postgresql://user:password@staging-host/staging_db",
    databricks = "databricks://token:dapi...@workspace.cloud.databricks.com:443/default",
}
```

**Benefits**: Execute queries, browse schemas, view results without leaving Neovim.

#### 2.3 Enhanced SQL Formatting

**Update**: `nvim/.config/nvim/lua/plugins/init.lua:334`

```lua
formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    sql = {
        "sqlfluff",
        -- OR configure for specific dialects:
        -- "sql_formatter", -- generic
    },
},
```

**Add SQL dialect configuration**: `~/.config/nvim/local.lua`

```lua
-- SQLFluff configuration for Databricks SQL
vim.g.sqlfluff_dialect = "databricks"  -- or "spark", "hive"
```

**Create**: `~/.sqlfluff` for project-specific rules

```ini
[sqlfluff]
dialect = databricks
templater = raw
max_line_length = 100

[sqlfluff:indentation]
indent_unit = space
tab_space_size = 4
```

**Benefits**: Consistent SQL formatting across team, dialect-specific rules.

#### 2.4 SQL Syntax Enhancements

**Update**: `nvim/.config/nvim/lua/plugins/treesitter.lua:11`

```lua
ensure_installed = {
    "bash",
    "diff",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",
    "python",
    "sql",        -- Add this
    "hcl",        -- For Terraform (infrastructure as code)
    "yaml",       -- For configs
    "json",       -- For data files
},
```

**Benefits**: Better SQL syntax highlighting and code navigation.

### 3. Databricks-Specific Integration

#### 3.1 Databricks CLI Integration

**New File**: `nvim/.config/nvim/lua/plugins/databricks.lua`

```lua
return {
    {
        "nvim-telescope/telescope.nvim",
        -- Add to existing telescope config
        keys = {
            -- Databricks-specific searches
            {
                "<leader>Db",
                function()
                    require("telescope.builtin").find_files({
                        prompt_title = "Databricks Notebooks",
                        cwd = vim.fn.expand("~/databricks"),  -- or your sync folder
                        find_command = { "find", ".", "-type", "f", "-name", "*.py" },
                    })
                end,
                desc = "[D]atabricks [N]otebooks",
            },
        },
    },
}
```

**Add custom commands**: `nvim/.config/nvim/lua/config/databricks.lua`

```lua
-- Databricks utility functions
local M = {}

-- Sync current file to Databricks workspace
function M.sync_to_databricks()
    local file = vim.fn.expand("%:p")
    local workspace_path = "/Workspace/Users/" .. vim.env.USER
    vim.cmd("!databricks workspace import " .. file .. " " .. workspace_path)
end

-- Run current notebook on cluster
function M.run_notebook()
    local notebook = vim.fn.expand("%:t:r")
    vim.cmd("!databricks jobs run-now --notebook-path /Workspace/... ")
end

-- List clusters
function M.list_clusters()
    vim.cmd("split | terminal databricks clusters list")
end

-- Keybindings
vim.keymap.set("n", "<leader>Ds", M.sync_to_databricks, { desc = "[D]atabricks [S]ync" })
vim.keymap.set("n", "<leader>Dr", M.run_notebook, { desc = "[D]atabricks [R]un" })
vim.keymap.set("n", "<leader>Dc", M.list_clusters, { desc = "[D]atabricks [C]lusters" })

return M
```

**Source**: `nvim/.config/nvim/init.lua` (add after line 5)

```lua
require("config.databricks")
```

**Benefits**: Sync notebooks, run jobs, manage clusters without terminal switching.

#### 3.2 PySpark Development Support

**Update**: `nvim/.config/nvim/lua/plugins/init.lua` (add to LSP settings)

```lua
pyright = {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                extraPaths = {
                    -- Add PySpark stub paths
                    vim.fn.expand("~/.local/lib/python3.x/site-packages/pyspark-stubs"),
                },
            }
        }
    }
},
```

**Add snippet file**: `nvim/.config/nvim/snippets/python.lua`

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("pyspark_init", {
        t({"from pyspark.sql import SparkSession", ""}),
        t({"", "spark = SparkSession.builder \\"}),
        t({"", "    .appName(\""}), i(1, "app_name"), t({"\") \\"}),
        t({"", "    .getOrCreate()"}),
    }),
    s("read_delta", {
        t("df = spark.read.format(\"delta\").load(\""),
        i(1, "path/to/table"),
        t("\")"),
    }),
    s("write_delta", {
        t("df.write.format(\"delta\").mode(\""),
        i(1, "overwrite"),
        t("\").save(\""),
        i(2, "path/to/table"),
        t("\")"),
    }),
}
```

**Benefits**: Auto-completion for PySpark APIs, quick boilerplate insertion.

### 4. Additional Data Engineering Tools

#### 4.1 CSV/Data File Preview

**New File**: `nvim/.config/nvim/lua/plugins/data-preview.lua`

```lua
return {
    {
        "chrisbra/csv.vim",
        ft = { "csv", "tsv" },
        config = function()
            vim.g.csv_delim = ","
            vim.g.csv_arrange_align = "l*"

            -- Keybindings for CSV navigation
            vim.keymap.set("n", "<leader>ca", ":CSVArrangeColumn<CR>", { desc = "[C]SV [A]rrange" })
            vim.keymap.set("n", "<leader>cu", ":CSVUnArrangeColumn<CR>", { desc = "[C]SV [U]narrange" })
        end,
    },
}
```

**Benefits**: View and navigate CSV files in aligned column format.

#### 4.2 YAML/JSON Validation

**Update**: `nvim/.config/nvim/lua/plugins/init.lua:278`

```lua
vim.list_extend(ensure_installed, {
    "stylua",
    "ruff",
    "sqlfmt",
    "sqlfluff",
    "sql-language-server",
    "yamllint",     -- Add
    "yamlfmt",      -- Add
    "jq",           -- Add for JSON formatting
    "ty",
})
```

**Update**: `nvim/.config/nvim/lua/plugins/init.lua:334`

```lua
formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    sql = { "sqlfluff" },
    yaml = { "yamlfmt" },      -- Add
    json = { "jq" },           -- Add
},
```

**Benefits**: Validate data pipeline configurations, format config files.

#### 4.3 Git Integration Enhancements

**Update**: `nvim/.config/nvim/lua/plugins/init.lua` (add new plugin)

```lua
{
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
    },
    config = function()
        require("neogit").setup({})
        vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Neo[g]it" })
    end,
},
{
    "sindrets/diffview.nvim",
    config = function()
        vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "[G]it [D]iff" })
        vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory %<CR>", { desc = "[G]it [H]istory" })
    end,
},
```

**Benefits**: Review PRs, compare branches, view file history visually.

### 5. Workflow Optimization

#### 5.1 Better Which-Key Groups

**Update**: `nvim/.config/nvim/lua/plugins/whichkey.lua:43`

```lua
spec = {
    { "<leader>a", group = "[a]i", mode = { "n", "x" } },
    { "<leader>c", group = "[c]ode", mode = { "n", "x" } },
    { "<leader>cq", vim.diagnostic.setloclist, mode = { "n" }, desc = "Open quickfix list" },
    { "<leader>d", group = "[d]ocument/[d]ebug" },  -- Updated
    { "<leader>D", group = "[D]atabase" },           -- New
    { "<leader>m", group = "[m]arkdown" },
    { "<leader>r", group = "[r]ename" },
    { "<leader>f", group = "[f]ind" },
    { "<leader>F", group = "[F]ile" },
    { "<leader>Fe", "<cmd>NvimTreeToggle<cr>", desc = "File Tree" },
    { "<leader>w", group = "[w]orkspace" },
    { "<leader>t", group = "[t]oggle/[t]est" },      -- Updated
    { "<leader>h", group = "Git [h]unk", mode = { "n", "v" } },
    { "<leader>g", group = "[g]it" },                 -- New
    { "<leader>s", group = "[s]ettings" },
    { "<leader>v", group = "[v]env" },                -- New
    { "<leader>j", group = "[j]upyter" },             -- New
},
```

#### 5.2 Project-Specific Settings

**Create**: `nvim/.config/nvim/lua/config/projects.lua`

```lua
-- Auto-detect project type and load specific settings
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.py" },
    callback = function()
        -- Check if in a Databricks project
        local root = vim.fn.getcwd()
        if vim.fn.filereadable(root .. "/.databricks") == 1 then
            -- Load Databricks-specific settings
            vim.opt_local.colorcolumn = "100"  -- Databricks notebook width
            -- Could also set specific formatters, etc.
        end
    end,
})

-- Auto-detect SQL dialect
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.sql" },
    callback = function()
        local first_line = vim.fn.getline(1)
        if string.match(first_line, "databricks") or string.match(first_line, "spark") then
            vim.b.sql_dialect = "databricks"
        end
    end,
})
```

**Source**: Add to `nvim/.config/nvim/init.lua`

```lua
require("config.projects")
```

#### 5.3 Custom Autocommands

**Update**: `nvim/.config/nvim/lua/config/autocmds.lua`

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Auto-format SQL on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.sql" },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- Set Python indentation for Databricks notebooks
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end,
})

-- Automatically source .nvim.lua files in project root
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local nvim_lua = vim.fn.getcwd() .. "/.nvim.lua"
        if vim.fn.filereadable(nvim_lua) == 1 then
            dofile(nvim_lua)
        end
    end,
})
```

**Benefits**: Consistent formatting, project-specific overrides, auto-configuration.

## Implementation Priority

### Phase 1: Immediate Impact (Week 1)
1. Configure Ruff LSP server (ruff-lsp) for Python - you already have Ruff!
2. Configure ty LSP for type checking - you already have ty installed!
3. Add SQL LSP (sql-language-server)
4. Configure virtual environment selector
5. Update Treesitter with sql, yaml, json parsers

### Phase 2: Developer Experience (Week 2)
1. Add DAP for Python debugging
2. Install dadbod for database queries
3. Add test runner (neotest)
4. Configure better which-key groups
5. Add CSV preview plugin

### Phase 3: Advanced Workflows (Week 3-4)
1. Jupyter/Molten integration
2. Databricks CLI integration
3. PySpark snippets and configuration
4. Git workflow enhancements (Neogit, Diffview)
5. Project-specific autocommands

### Phase 4: Polish (Ongoing)
1. Custom snippets for common patterns
2. Team-specific configurations
3. Performance tuning
4. Documentation

## Configuration Management

### Machine-Specific Settings

Keep sensitive or machine-specific configs in `~/.config/nvim/local.lua`:

```lua
-- Database connections (not committed to git)
vim.g.dbs = {
    dev = "postgresql://...",
    staging = "databricks://...",
}

-- Databricks config
vim.g.databricks_host = "https://workspace.cloud.databricks.com"
vim.g.databricks_token = os.getenv("DATABRICKS_TOKEN")

-- Python paths
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/3.11.0/bin/python")
```

### Team-Shared Settings

Keep team configs in the dotfiles repo for consistency across team members.

## Performance Considerations

1. **Lazy Loading**: Most plugins are already lazy-loaded, maintain this pattern
2. **LSP Startup**: Only enable LSPs you actively use
3. **Treesitter**: Limit `ensure_installed` to languages you use
4. **Large Files**: Consider adding:

```lua
-- Disable features for large files (>1MB)
vim.api.nvim_create_autocmd("BufReadPre", {
    callback = function()
        local filesize = vim.fn.getfsize(vim.fn.expand("%"))
        if filesize > 1024 * 1024 then
            vim.opt_local.syntax = "off"
            vim.opt_local.foldmethod = "manual"
        end
    end,
})
```

## Python LSP Strategy: Astral's Complete Stack

You're already using the modern Astral tooling stack! Here's how Ruff and ty work together:

### Option 1: Ruff LSP Only (Lightweight)
**Pros**:
- Extremely fast
- Single tool for linting, formatting, and code actions
- Low resource usage
- Great for data scripts and notebooks

**Cons**:
- No type checking
- Limited go-to-definition for external libraries
- Basic completions

**Best for**: Quick scripts, notebooks, exploratory data analysis

### Option 2: Ruff LSP + ty (Recommended - Astral Stack)
**Pros**:
- **Blazing fast**: Both written in Rust
- **Ruff**: Fast linting + formatting + code actions
- **ty**: 10-60x faster than Pyright type checking
- **Advanced features**:
  - First-class intersection types
  - Superior type narrowing
  - Reachability analysis (fewer false positives)
- **Unified tooling**: Same vendor, designed to work together
- **Low resource usage**: Rust performance for both tools

**Cons**:
- ty is in beta (but production-ready, targeting stable 1.0 in 2026)
- Slightly less mature than Pyright (but rapidly improving)

**Best for**: Production code, team projects, data engineering pipelines

### Why ty over Pyright?

| Feature | ty | Pyright |
|---------|-----|---------|
| **Speed** | 10-60x faster | Baseline |
| **Language** | Rust | TypeScript |
| **Vendor** | Astral (Ruff, uv) | Microsoft |
| **Type narrowing** | Advanced | Good |
| **False positives** | Fewer (reachability analysis) | More assumptions |
| **Maturity** | Beta (very usable) | Stable |
| **Integration** | Native with Ruff | Separate vendor |

**Recommendation**: Use Ruff LSP + ty for the complete Astral stack. You already have ty installed!

## Testing the Configuration

After implementing changes:

1. **LSP Health Check**: `:checkhealth lsp`
2. **Mason Status**: `:Mason` - verify all tools installed
3. **Treesitter Status**: `:TSInstallInfo`
4. **Plugin Status**: `:Lazy` - check for errors
5. **Test LSP**: Open a Python file, try `gd` (go to definition)
6. **Test Formatting**: Open SQL file, use `<leader>cf`
7. **Test Database**: `:DBUIToggle` and try connecting

## Resources

### Python Tooling (Astral Stack)
- **ty (Type Checker)**: https://github.com/astral-sh/ty
- **ty Documentation**: https://docs.astral.sh/ty/
- **ty Editor Settings**: https://docs.astral.sh/ty/reference/editor-settings/
- **Ruff**: https://github.com/astral-sh/ruff
- **Astral Blog - ty Announcement**: https://astral.sh/blog/ty

### LSP & Development Tools
- **SQL LSP**: https://github.com/joe-re/sql-language-server
- **Dadbod**: https://github.com/tpope/vim-dadbod
- **Molten (Jupyter)**: https://github.com/benlubas/molten-nvim
- **Neotest**: https://github.com/nvim-neotest/neotest

### Databricks
- **Databricks CLI**: https://docs.databricks.com/dev-tools/cli/

## Conclusion

Your configuration already has a solid foundation with the modern Astral stack (Ruff + ty). The recommended enhancements will transform it into a comprehensive data engineering IDE with:

- ✅ Full Python development capabilities (Ruff LSP + ty type checking, debugging, testing)
- ✅ Professional SQL editing (LSP, formatting, query execution)
- ✅ Databricks workflow integration
- ✅ Data file handling (CSV, JSON, YAML)
- ✅ Git workflow optimization

**Key Next Steps**:
1. Enable Ruff LSP server (you already have Ruff installed!)
2. Enable ty LSP server (you already have ty installed!)
3. Add SQL LSP for database development
4. Configure DAP for debugging
5. Add database client (vim-dadbod)

**Your Tooling Advantage**: You're already using the cutting-edge Astral stack (Ruff + ty), which is faster and more modern than traditional Python tooling (Pyright, mypy). Just need to configure them as LSP servers!

Implementation should follow the phased approach, with Phase 1 providing immediate productivity gains. All changes maintain the current clean, modular structure.

---

## Sources

Information about ty type checker and LSP configuration was gathered from:

- [GitHub - astral-sh/ty: An extremely fast Python type checker and language server, written in Rust](https://github.com/astral-sh/ty)
- [ty: An extremely fast Python type checker and LSP - Astral Blog](https://astral.sh/blog/ty)
- [ty - Astral Official Documentation](https://docs.astral.sh/ty/)
- [ty: The Blazingly Fast Python Type Checker from Astral - DEV Community](https://dev.to/toyama0919/ty-the-blazingly-fast-python-type-checker-from-astral-ruff-uv-creators-5bd)
- [ty: Astral's New Python Type Checker Released – Python Developer Tooling Handbook](https://pydevtools.com/blog/ty-beta/)
- [Astral's ty: A New Blazing-Fast Type Checker for Python – Real Python](https://realpython.com/python-ty/)
- [Episode #506 - ty: Astral's New Type Checker (Formerly Red-Knot) | Talk Python To Me Podcast](https://talkpython.fm/episodes/show/506/ty-astrals-new-type-checker-formerly-red-knot)
- [Python type checker ty now in beta | InfoWorld](https://www.infoworld.com/article/4108979/python-type-checker-ty-now-in-beta.html)
- [Mike Olson - ty: A Fast Python Type Checker and LSP for Emacs](https://mwolson.org/blog/2025-12-17-ty-a-fast-python-type-checker-and-lsp-for-emacs/)
- [Editor settings | ty - Astral Docs](https://docs.astral.sh/ty/reference/editor-settings/)
- [How to try the ty type checker – Python Developer Tooling Handbook](https://pydevtools.com/handbook/how-to/how-to-try-the-ty-type-checker/)
