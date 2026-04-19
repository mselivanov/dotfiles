# Neovim Config — Modernization Notes

A reference for the `nvim/` stow package in this repo. Read once to get oriented; jump back when you're deciding what to add, prune, or rewire. Scope is a terminal-first development workflow focused on **Python (Databricks)**, **SQL (Spark/Databricks SQL)**, **Bash**, **PowerShell**, and config formats (**YAML / JSON / TOML**), driven alongside AI assistants (GitHub Copilot, CopilotChat, Claude Code).

Companion to the task file `ai/tasks/2026041901_update_neovim_config_to_use_latest_lsp_approach.md` and the plan at `~/.claude/plans/read-and-implement-task-modular-cocke.md`.

---

## 1. Primer — core Neovim concepts

A short refresher so the rest of the doc lands. Run `:help <topic>` for depth.

- **Modes.** Modal editing is the whole premise: `Normal` (move / operate), `Insert` (type), `Visual` / `Visual-Block` (select), `Command-line` (`:…`), `Terminal` (inside `:terminal`). Operators (`d`, `c`, `y`) + motions (`w`, `}`, `f{char}`) + text objects (`iw`, `ap`, `i"`) compose into the "sentence" of Vim editing. Modal cost pays off once muscle memory kicks in; until then, `:Tutor` and `vim-cool`/`which-key` (already installed) soften the curve.
- **Buffers / windows / tabs.** A *buffer* is a loaded file; a *window* is a viewport onto a buffer; a *tab* is a layout of windows. `:bnext` / `:bprev` are already mapped to `<S-l>` / `<S-h>`. Don't confuse tabs with browser tabs — tabs are layouts, buffers are the real "open files" list.
- **Registers.** Named clipboards: `"0` (last yank), `"+` (system clipboard), `"*` (primary selection on Linux), `".` (last insert). `:help registers`. This repo sets `clipboard = "unnamedplus"` so `y`/`p` talk to the system clipboard by default.
- **Autocmds and augroups.** Event-driven hooks: `BufWritePre`, `FileType python`, `LspAttach`, `TextYankPost`, etc. Always wrap related autocmds in a named `vim.api.nvim_create_augroup("<name>", { clear = true })` so reloading the module doesn't stack duplicates on the same event. Examples in this repo: the yank highlight in `lua/config/autocmds.lua`, and the LSP attach / highlight / detach group in `lua/config/lsp.lua`.
- **`:help` is the source of truth.** `K` on an identifier, `:checkhealth` for diagnostics, `:Telescope help_tags` for fuzzy doc search, `:messages` to recover lost output. LLM suggestions age fast; `:help` doesn't.
- **LSP.** Neovim 0.11+ uses a declarative `lsp/<server>.lua` convention plus `vim.lsp.config(name, cfg)` / `vim.lsp.enable({…})`. An `LspAttach` autocmd (not per-server `on_attach`) is the canonical place for buffer-local keymaps. `vim.diagnostic` is the surface for lints/errors regardless of producer.
- **Treesitter.** Incremental parser → AST per buffer. Unlocks precise highlighting, indent, and structural text objects (`af`/`if` for functions, `ac`/`ic` for classes) via `nvim-treesitter-textobjects`. Prefer treesitter-based motions over regex-driven ones once a language parser is installed.
- **Plugin manager.** `lazy.nvim` (current) adds event/cmd/ft triggers, automatic dependency ordering, a lockfile (`lazy-lock.json`), and a UI (`:Lazy`). The 0.12+ built-in `vim.pack` is simpler but lacks event-based lazy loading — see plan for the trade-off.
- **Filesystem layout.** `stdpath("config")` is `~/.config/nvim/` (this repo); `stdpath("data")` is `~/.local/share/nvim/` (plugins, mason, treesitter parsers); `stdpath("state")` is `~/.local/state/nvim/` (undofile, shada); `stdpath("cache")` is disposable. Runtimepath conventions: `lua/` (Lua modules), `plugin/` (auto-sourced on startup), `ftplugin/<lang>.lua` (auto-sourced when that filetype loads), `after/` (overrides), `lsp/<server>.lua` (new in 0.11, auto-discovered by `vim.lsp.enable`).

---

## 2. Audit of the current config

```
nvim/.config/nvim/
├── init.lua                         -- entry: loads config.*, lazy, plugins, config.lsp, optional local.lua
├── lazy-lock.json                   -- plugin version pins (committed)
├── lsp/                             -- NEW: per-server overrides picked up by vim.lsp.enable
│   ├── lua_ls.lua
│   ├── ruff.lua
│   └── ty.lua
├── lua/
│   ├── config/
│   │   ├── autocmds.lua             -- global autocmds (yank highlight)
│   │   ├── keymaps.lua              -- all non-LSP keymaps
│   │   ├── lazy.lua                 -- bootstraps lazy.nvim + its setup
│   │   ├── lsp.lua                  -- NEW: vim.lsp.config("*",…) + vim.lsp.enable + LspAttach autocmd
│   │   └── options.lua              -- vim.opt / vim.g (leaders, clipboard, UI)
│   └── plugins/
│       ├── init.lua                 -- the big plugin spec (returns a table for lazy)
│       ├── avante.lua               -- (currently empty/commented — candidate for deletion)
│       ├── bufferline.lua
│       ├── colorscheme.lua          -- nord
│       ├── nvim-tree.lua
│       ├── telescope.lua
│       ├── toggleterm.lua
│       ├── treesitter.lua
│       ├── whichkey.lua
│       └── zk-nvim.lua              -- note-taking integration with ~/brain
└── README.md
```

**What's already in good shape**
- Modular split (`config/` vs `plugins/`), `lazy-lock.json` committed, machine-local escape hatch via `require("local")` pcall.
- Strong core plugin set: `telescope`, `mini.nvim` (ai + surround + statusline), `conform`, `nvim-cmp`, `treesitter`, `gitsigns`, `fidget`, `which-key`, `toggleterm`.
- Domain-specific keymaps for SQL (MERGE UPDATE/VALUES generators) in `keymaps.lua:124–140` — a real productivity asset for Databricks work; keep them.
- LSP now uses the 0.11+ native pattern (`vim.lsp.config` + `vim.lsp.enable` + `lsp/<name>.lua`).

**What the modernization pass removed**
- `mason-lspconfig.nvim` dependency and its `handlers` callback (its v2 API is effectively redundant with `vim.lsp.enable`).
- ~250 lines of inline LSP setup in `plugins/init.lua`, collapsed into `lua/config/lsp.lua` + three `lsp/*.lua` overrides.
- Deprecated API calls: `vim.highlight.on_yank` → `vim.hl.on_yank`; `client.supports_method(…)` → `client:supports_method(…)`.
- Stray `print("DEBUG: Setting up lua_ls")` debug output.

**Remaining cleanup candidates**
- `plugins/avante.lua` — the avante plugin is commented out per `CLAUDE.md`; the file exists but contributes nothing. Delete it or replace with CopilotChat-equivalent config.
- `<C-]>` is mapped to `:ClaudeCode` in `keymaps.lua:120–121`, but no `claude-code.nvim` plugin is registered. Either add the plugin (`greggh/claude-code.nvim` or `coder/claudecode.nvim`) or remove the orphan keymap.
- `debug-vim-global.lua` at the repo root — looks like a troubleshooting scratchpad from investigating the `vim` global in `lua_ls`. Now that the `lsp/lua_ls.lua` override handles that cleanly, this file can probably be deleted.

---

## 3. Per-domain recommendations

Ordered roughly by ROI within each section. "Keep" = already installed and doing its job. "Add" = a gap worth filling. "Skip" = commonly recommended but redundant here.

### Python / Databricks

Primary daily driver. Optimize first.

- **Keep**
  - `ruff` LSP — single binary that does linting, import sort, and formatting. Replaces `flake8` + `isort` + `black`. Configure per-project in `pyproject.toml` under `[tool.ruff]`.
  - `ty` LSP — fast Astral type checker. Good replacement for `pyright`/`mypy` in the editor loop (still run `mypy` in CI if that's the project standard).
  - `conform.nvim` running `ruff_format` + `ruff_organize_imports` on save (already wired in `plugins/init.lua`).
  - `treesitter` with the `python` parser.
- **Add (high value)**
  - `nvim-dap` + `mfussenegger/nvim-dap-python` — step-through debugging. For Databricks, point it at a local `databricks-connect` Python interpreter; you get breakpoints in notebooks-as-scripts and in `.py` files in bundle projects.
  - `jupytext` CLI + `GCBallesteros/jupytext.nvim` (or just shell aliases) — round-trip `.py` ↔ `.ipynb` so Databricks notebooks edit cleanly as Python files.
  - `SchemaStore.nvim` for `databricks.yml` (Databricks Asset Bundles) — see the YAML section below; it's where DAB config gets real ergonomic wins.
  - `lervag/vimtex`-style filetype plugin for `.dbc`? No — `.dbc` is a zip, not worth editor support. Stick to `.py` / `.sql` / `.yml` in bundles.
- **Consider**
  - `otter.nvim` — runs LSPs inside fenced code blocks. Worth it if you edit notebooks-as-markdown or literate Python; skip otherwise.
  - `basedpyright` as a companion LSP alongside `ruff` and `ty` — only if `ty`'s accuracy isn't enough for your codebase. Two type checkers on the same buffer double the diagnostic noise.
- **Skip / drop**
  - `pyright` — overlapping with `ty`; pick one.
  - `black`, `isort`, `flake8` — all covered by `ruff`. Remove from any `requirements-dev.txt` duplication.
  - `pylsp` / `python-lsp-server` — legacy; `ruff` + `ty` covers it.

### SQL (Spark SQL / Databricks SQL dialect)

- **Keep**
  - `sqlfluff` (lint) + `sqlfmt` (format) via `conform`. Put `.sqlfluff` in project root with `dialect = sparksql` to calibrate.
  - `treesitter` with `sql` parser.
  - The SQL-specific keymaps in `keymaps.lua` (`<leader>rp`, `<leader>rd`, `<leader>mu`, `<leader>mv`) — codebase-specific productivity, keep them.
- **Add**
  - `tpope/vim-dadbod` + `kristijanhusak/vim-dadbod-completion` + `kristijanhusak/vim-dadbod-ui` — run queries against a live Databricks SQL warehouse from Neovim. Requires `databricks` CLI + ODBC driver configured; connection string goes in `~/.config/nvim/local.lua` or env vars so it doesn't get committed.
- **Consider**
  - `sqls` / `sqlls` LSP — general SQL completion, but authentication against Databricks SQL warehouses is fiddly. Low priority; dadbod fills most of the need.
- **Skip**
  - dialect-specific LSPs (e.g. PostgreSQL's pg_ls); not relevant to Spark SQL.

### Bash

- **Add**
  - `bashls` LSP (`bash-language-server` npm package, Mason-installable). Surfaces `shellcheck` diagnostics when `shellcheck` is on PATH.
  - `shellcheck` (Mason — already implied by `bashls`, but make it explicit in `ensure_installed`).
  - `shfmt` (Mason) wired into `conform` under `sh = { "shfmt" }` with `{ "-i", "2" }` if you prefer 2-space indent.
- **Keep**
  - `treesitter` with `bash` parser.

### PowerShell

- **Add**
  - `powershell_es` LSP (PowerShellEditorServices bundle; Mason-installable). It bundles formatting and PSScriptAnalyzer — no separate `conform` entry needed.
  - `treesitter` with `powershell` parser.
- **Note**
  - Neovim's built-in filetype detection handles `.ps1`, `.psm1`, `.psd1` without extra config. `.ps1xml` is XML — covered by `xmlls`/`lemminx` if you ever need it.

### YAML / JSON / TOML

- **Add**
  - `yamlls` (Red Hat YAML LSP) — Mason-installable — wired with `b0o/SchemaStore.nvim` for schema lookup. Huge win for `databricks.yml` (DAB), GitHub Actions, `docker-compose.yml`, Kubernetes.
  - `jsonls` + SchemaStore — schema-aware completion for `tsconfig.json`, `package.json`, `launch.json`, etc.
  - `taplo` LSP — handles TOML; also a CLI formatter. One binary covers both roles.
- **Per-server config stubs** go in `lsp/yamlls.lua`, `lsp/jsonls.lua`, `lsp/taplo.lua` alongside the existing three. Example `lsp/yamlls.lua`:
  ```lua
  return {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
        format = { enable = true },
        validate = true,
      },
    },
  }
  ```

### AI assistants (terminal-first)

- **Keep**
  - `github/copilot.vim` — inline ghost-text completion, toggled via `<C-J>`. The per-filetype toggle (`python/sql/shell` on, everything else off) in `plugins/init.lua:5–16` is sensible for a data-engineering workflow where you don't want Copilot volunteering in markdown.
  - `CopilotC-Nvim/CopilotChat.nvim` — chat UI for Copilot. Works in the terminal.
- **Decide**
  - Claude Code integration. The keymap at `keymaps.lua:120–121` references `:ClaudeCode`, but the plugin isn't in the spec. Options:
    1. Add `greggh/claude-code.nvim` (floating-window terminal wrapper) or `coder/claudecode.nvim` (richer IDE-style integration).
    2. Remove the orphan keymap and just use `:terminal claude` directly (already ergonomic because of toggleterm).
- **Drop**
  - `avante.nvim` — currently commented out; its niche overlaps with CopilotChat + Claude Code. Delete `plugins/avante.lua`.

---

## 4. Ergonomics wins (domain-agnostic)

Low-cost additions that pay back across every language above.

- `telescope-fzf-native.nvim` — C-speed sorter for telescope. Drop-in, massively faster than the default Lua matcher on large repos.
- `nvim-treesitter-textobjects` — adds `af`/`if`/`ac`/`ic`/`aa`/`ia` (around/inside function/class/parameter) motions for every installed parser. Single best "learn once, use everywhere" motion pack.
- `folke/flash.nvim` (or `leap.nvim`) — quick 2-char jumps; replaces `/search<CR>n` roundtrips.
- `folke/trouble.nvim` — workspace-wide diagnostics panel. Much better than `:copen` after a lint run; integrates with `vim.diagnostic` so it picks up ruff/ty/sqlfluff/bashls/etc.
- `folke/snacks.nvim` — consolidated utilities (notifier, dashboard, bigfile, input, picker). Candidate to replace several small plugins later.

---

## 5. Things to leave alone

- **Bash-it, Starship, tmux** — separate stow packages. Neovim changes shouldn't touch them.
- **Machine-local overrides** — `init.lua:7–9` does a `pcall(require, "local")`. Keep using `~/.config/nvim/local.lua` (not tracked) for work/personal divergence: Databricks workspace URLs, proxy settings, paths to company-specific linters. `.tmux.conf.local` and `.bashrc.local` do the same job in their respective packages.
- **Lazy.nvim for now.** The plan covers why `vim.pack` isn't a straight upgrade for this plugin set. Revisit when `vim.pack` grows event-based lazy loading, or when you hit a concrete pain point with lazy.

---

## 6. Follow-up checklist

Roughly ordered by value per minute.

- [ ] Add `bashls`, `shellcheck`, `shfmt`, `powershell_es`, `yamlls`, `jsonls`, `taplo` to `mason-tool-installer` `ensure_installed` in `plugins/init.lua`.
- [ ] Add matching `lsp/<name>.lua` stubs under `nvim/.config/nvim/lsp/`.
- [ ] Add `SchemaStore.nvim` as a dep of `nvim-lspconfig` and wire it into `lsp/yamlls.lua` + `lsp/jsonls.lua`.
- [ ] Extend `conform.nvim` `formatters_by_ft` with `sh = { "shfmt" }`.
- [ ] Extend treesitter `ensure_installed` with `bash`, `powershell`, `yaml`, `json`, `toml` (and verify `python`, `sql`, `lua` already in).
- [ ] Decide Claude Code plugin vs. orphan keymap; either install the plugin or delete `keymaps.lua:120–121`.
- [ ] Delete `plugins/avante.lua` and `debug-vim-global.lua` if confirmed unused.
- [ ] Consider `vim-dadbod` stack for live Databricks SQL; `nvim-dap` + `nvim-dap-python` for Python debugging.
- [ ] Add `telescope-fzf-native.nvim`, `nvim-treesitter-textobjects`, and `trouble.nvim` for general ergonomics.
- [ ] Revisit `vim.pack` migration in ~6 months (late 2026) once event-trigger support or conventions mature.
