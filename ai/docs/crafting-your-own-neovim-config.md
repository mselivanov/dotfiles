# Crafting Your Own Neovim Config

A step-by-step map of what to set up, in what order, and which Neovim concept sits behind each decision. Aimed at someone who has used a "distribution" (LazyVim, NvChad, kickstart.nvim) and now wants to build a config they fully understand.

Sequence matters: later steps assume earlier ones. Skim first, then follow linearly on a fresh `~/.config/nvim/`.

---

## Step 0 — Know what's already there

Before writing a single line, read:

- `:help nvim-quickstart` — the official crash course.
- `:help startup` — the exact order Neovim loads files at launch.
- `:help runtimepath` — the search path that underlies *everything* (plugins, queries, ftplugins, after/, colorscheme files).
- `:help stdpath` — where Neovim expects config vs data vs state vs cache to live.

Helpful external:
- Official user manual index — <https://neovim.io/doc/user/>
- Neovim 0.11 & 0.12 what's-new posts — <https://gpanders.com/blog/whats-new-in-neovim-0-11/>, <https://neovim.io/doc/user/news.html>
- Kickstart.nvim as a reference distro — <https://github.com/nvim-lua/kickstart.nvim> (single-file starter; great for cross-referencing)

**Key concept: Neovim ≠ Vim at the config layer.** You will write Lua, not vimscript. Vimscript still works (`.vim` files), but idiomatic Neovim is Lua for everything new.

---

## Step 1 — The entry point and project layout

Neovim looks for `$XDG_CONFIG_HOME/nvim/init.lua` (= `~/.config/nvim/init.lua` on Linux/macOS). Anything you put in the `lua/` subdirectory becomes `require()`-able.

**Concept: `runtimepath` + `lua/` package search.**
`require("foo.bar")` → searches every `<rtp>/lua/foo/bar.lua`. The config directory and every installed plugin are on runtimepath, which is why plugins can ship Lua modules you just `require`.

**Minimum viable layout:**

```
~/.config/nvim/
├── init.lua                -- only requires modules; no logic
├── lua/
│   ├── config/
│   │   ├── options.lua     -- vim.opt / vim.g
│   │   ├── keymaps.lua     -- vim.keymap.set
│   │   ├── autocmds.lua    -- vim.api.nvim_create_autocmd
│   │   └── lazy.lua        -- plugin manager bootstrap (see Step 7)
│   └── plugins/            -- one file per plugin or logical group
│       └── ...
└── lsp/                    -- one file per LSP server (Neovim 0.11+)
    └── ...
```

`init.lua` ends up being five lines of `require`s. Keep it that way — logic lives in modules.

**Read**: `:help lua-require`, `:help lua-guide`, `:help 'runtimepath'`.
**External**: <https://neovim.io/doc/user/lua-guide.html>

---

## Step 2 — Options (`vim.opt`, `vim.g`, `vim.o`)

**Concept.** Neovim has three option scopes: *global*, *window-local*, *buffer-local*. `vim.opt` is the modern Lua handle that dispatches to the right one and understands list/map values. `vim.g` is for global variables (usually plugin-facing: `vim.g.mapleader = " "`). `vim.o` is string-typed — avoid unless you need the raw value.

Typical early-config settings to form opinions on:

- `number`, `relativenumber` — line numbers.
- `expandtab`, `tabstop`, `shiftwidth` — indentation behavior.
- `ignorecase`, `smartcase` — search semantics.
- `undofile` — persistent undo.
- `clipboard = "unnamedplus"` — system clipboard integration.
- `signcolumn = "yes"` — avoids layout jitter when diagnostics appear.
- `updatetime`, `timeoutlen` — responsiveness tuning.
- Leader keys: `vim.g.mapleader`, `vim.g.maplocalleader`. Set these *before* loading plugins so plugin `<leader>` mappings resolve correctly.

**Read**: `:help vim.opt`, `:help option-summary`, `:help 'mapleader'`.
**External**: <https://neovim.io/doc/user/options.html>

---

## Step 3 — Keymaps (`vim.keymap.set`)

**Concept: modal editing.** Mappings are per-mode. Common modes:

| Code | Mode |
|---|---|
| `n` | Normal |
| `i` | Insert |
| `v` | Visual (char + line) |
| `x` | Visual (char only, excludes select) |
| `s` | Select |
| `o` | Operator-pending |
| `t` | Terminal |
| `c` | Command-line |

Canonical call:

```lua
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save buffer" })
```

Principles worth internalizing:
- Prefer `<cmd>` over `:` — `<cmd>` doesn't change mode.
- Always provide `desc = ...` — which-key, telescope, and `:verbose map` all use it.
- Buffer-local maps (`buffer = bufnr`) are the right tool for LSP keymaps (see Step 8) and filetype-specific bindings (Step 6).
- Understand "recursive" vs "non-recursive" — `vim.keymap.set` is non-recursive (`noremap = true`) by default. Good.

**Read**: `:help vim.keymap.set`, `:help map-table`, `:help mapleader`.
**External**: <https://learnvimscriptthehardway.stevelosh.com/chapters/03.html> (old but the model is timeless).

---

## Step 4 — Autocmds and augroups

**Concept: event-driven hooks.** Neovim fires named events (`BufWritePre`, `FileType`, `LspAttach`, `TextYankPost`, `VimEnter`, …). Autocmds are callbacks registered against one or more events.

**The augroup rule.** Always wrap related autocmds in a named group with `clear = true`:

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("my-yank-highlight", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
```

`clear = true` means re-sourcing the module won't stack duplicate callbacks on the same event. Without it, every `:source %` doubles every handler — a classic source of phantom slowness.

Common productive autocmds:
- `TextYankPost` → highlight the yanked region briefly.
- `BufWritePre` → trim trailing whitespace, run formatter.
- `FileType` → set buffer-local options or keymaps for a language.
- `LspAttach` → wire LSP keymaps when a server attaches.
- `VimResized` → redraw statuslines / plugins that cache window geometry.

**Read**: `:help autocmd`, `:help autocmd-events`, `:help vim.api.nvim_create_autocmd()`, `:help augroup`.
**External**: <https://neovim.io/doc/user/autocmd.html>

---

## Step 5 — The runtimepath conventions you get for free

Before you reach for plugins, know the directories Neovim auto-discovers on runtimepath:

| Path | Purpose |
|---|---|
| `plugin/*.{lua,vim}` | Sourced once at startup. Global commands, `vim.g.*` defaults. |
| `ftplugin/<lang>.{lua,vim}` | Sourced when the filetype first appears. Ideal place for buffer-local options/keymaps. |
| `ftdetect/<lang>.{lua,vim}` | Filetype detection rules. |
| `after/` | Mirrors the above but runs *after* everything else — overrides. |
| `queries/<lang>/*.scm` | Treesitter queries. |
| `lsp/<server>.lua` | Per-LSP-server config (Neovim 0.11+). |
| `colors/*.{lua,vim}` | Colorschemes discoverable via `:colorscheme`. |

Learning to use `ftplugin/` is a big leap — most "I want indent=2 only for Lua" needs belong there, not in a central `autocmd` switch statement.

**Read**: `:help runtimepath`, `:help ftplugin`, `:help after-directory`, `:help vim.filetype.add()`.

---

## Step 6 — Filetype handling

**Concept.** Neovim maps files to *filetypes* (a string like `python`, `lua`, `sh`). Filetype detection uses extensions, shebangs, and content heuristics; you can extend it via `vim.filetype.add({...})`.

Workflow:
1. Open a file, run `:set ft?` — confirms the detected filetype.
2. Buffer-local settings belong in `ftplugin/<lang>.lua`:
   ```lua
   -- ~/.config/nvim/ftplugin/lua.lua
   vim.bo.expandtab = true
   vim.bo.shiftwidth = 2
   vim.bo.tabstop = 2
   ```
3. Complex wiring (LSP keymaps, treesitter opts) usually belongs in a `FileType` autocmd in a module, not inline in `ftplugin/`.

**Read**: `:help filetype`, `:help vim.filetype.add()`, `:help ftplugin`.

---

## Step 7 — Pick a plugin manager

The choice is mostly between two:

- **`lazy.nvim`** — de-facto standard. Event/cmd/ft lazy loading, dependency resolution, lockfile, `:Lazy` UI. Opinionated spec format.
  - Docs: <https://lazy.folke.io/>
  - Spec reference: <https://lazy.folke.io/spec>
- **`vim.pack`** — built into Neovim 0.12, minimal. No lazy triggers, no auto-dep ordering. Good for small configs or people who want zero plugin-manager dependency.
  - `:help vim.pack`

**Principle: bootstrap inline.** Don't `git clone` by hand — make `init.lua` self-healing:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
                  "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({ { import = "plugins" } })
```

Machines stay disposable; cloning the repo + `nvim --headless "+Lazy sync" +qa` is enough.

**Concept: plugin spec.** Most plugins get configured declaratively inside the spec. Event/cmd/ft keys control when the plugin is loaded. Abuse of this is how you end up with fast configs:

```lua
{ "windwp/nvim-autopairs", event = "InsertEnter", opts = { check_ts = true } },
```

**Read plugin READMEs directly.** LazyVim/NvChad/etc. wrap and hide defaults; the upstream README is the truth.

---

## Step 8 — LSP (Neovim 0.11+ native)

Neovim 0.11 introduced a native declarative LSP config flow that largely replaces `nvim-lspconfig`'s setup boilerplate.

**Concept stack:**
- A **language server** is an external process speaking LSP over stdio (e.g. `pyright`, `ruff`, `lua-language-server`).
- `vim.lsp.config(name, cfg)` registers or extends the config for a server.
- `vim.lsp.enable({ "lua_ls", "ruff" })` activates those servers (installs `FileType` autocmds to spawn the server when matching files open).
- Configs can live per-file under `<runtimepath>/lsp/<name>.lua` — just `return { ... }` from the file. Auto-discovered.
- `LspAttach` autocmd is the place for buffer-local keymaps:

  ```lua
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
      local map = function(k, fn, d) vim.keymap.set("n", k, fn, { buffer = event.buf, desc = d }) end
      map("gd", vim.lsp.buf.definition, "Goto Definition")
      map("<leader>rn", vim.lsp.buf.rename, "Rename")
      -- ...
    end,
  })
  ```

Still useful next to native LSP:
- `nvim-lspconfig` — now mostly a shipping mechanism for default `cmd` / `filetypes` / `root_markers` that `vim.lsp.config` picks up automatically. Install it; it stays invisible.
- `mason.nvim` + `mason-tool-installer.nvim` — install LSP servers, formatters, linters into `~/.local/share/nvim/mason`.
- `folke/lazydev.nvim` — makes `lua_ls` aware of the Neovim Lua runtime + your plugins.

**Read**: `:help lsp`, `:help vim.lsp.config`, `:help vim.lsp.enable`, `:help LspAttach`.
**External**:
- <https://neovim.io/doc/user/lsp.html>
- <https://github.com/neovim/nvim-lspconfig>
- <https://github.com/mason-org/mason.nvim>
- VonHeikemen's LSP guide (terse, up to date) — <https://lsp-zero.netlify.app/docs/>

---

## Step 9 — Treesitter

**Concept.** Incremental parser per buffer. Unlocks precise syntax highlighting, folds, structural textobjects, injections (language-in-language). See the companion doc `treesitter-in-neovim.md` for the full mental model — this section is just the checklist.

Per filetype you care about, enable three things:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua", "bash", ... },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr   = "v:lua.vim.treesitter.foldexpr()"
  end,
})
```

Install parsers either via `nvim-treesitter` (needs `tree-sitter` CLI on the new `main` branch) or by relying on Neovim's bundled set. Add `nvim-treesitter-textobjects` for `af`/`if`/`ac`/`ic` motions — highest-ROI addon.

**Read**: `:help treesitter`, `:help vim.treesitter.start()`, `:help treesitter-highlight`, `:help treesitter-query`.
**External**:
- <https://tree-sitter.github.io/tree-sitter/>
- <https://github.com/nvim-treesitter/nvim-treesitter>

---

## Step 10 — Completion, formatting, diagnostics

Three separate surfaces, commonly confused.

**Completion.** The UI that shows suggestions as you type.
- `hrsh7th/nvim-cmp` — established, configurable, large ecosystem. Slower startup.
- `Saghen/blink.cmp` — newer, faster, tighter default integration with `vim.lsp.config`.
- Built-in `:h ins-completion` — `<C-x><C-o>`, `<C-x><C-n>` — works without plugins for the minimalist.

**Formatting.** Run a formatter on save / on demand.
- `stevearc/conform.nvim` — the clean choice. One config maps `filetype → list of formatters`. Falls back to LSP formatting if none defined.
- `:help vim.lsp.buf.format()` — no plugin, just LSP.

**Diagnostics.** The lints/errors side of things. Source-agnostic: LSP servers, `nvim-lint`, treesitter linters all publish into `vim.diagnostic`. UI config is `vim.diagnostic.config({...})`.

**Read**: `:help vim.diagnostic`, `:help ins-completion`.
**External**:
- <https://github.com/stevearc/conform.nvim>
- <https://github.com/hrsh7th/nvim-cmp> / <https://github.com/Saghen/blink.cmp>
- <https://github.com/mfussenegger/nvim-lint>

---

## Step 11 — Debugging your config

The tools to reach for, in order:

- `:messages` — the last thing a print / error said. You'll hit this five times a day.
- `:checkhealth` — an umbrella. `:checkhealth lsp`, `:checkhealth vim.treesitter`, `:checkhealth <plugin>` surface broken state cleanly.
- `:Inspect` — under the cursor: which highlight groups + LSP tokens apply. Best tool for "why is this word the wrong color?"
- `:InspectTree` — live parse tree. For query-writing and treesitter debugging.
- `:verbose map <lhs>` / `:verbose set <option>?` — shows *where* a mapping or option was last set.
- `:Lazy profile` (or `--startuptime /tmp/start.log`) — attribute startup cost to plugins.
- `:lua = <expr>` — REPL one-liner for any Lua expression.

**Read**: `:help :checkhealth`, `:help :Inspect`, `:help :verbose`.

---

## Step 12 — Machine-specific overrides

Inevitably: work laptop needs proxy settings, personal laptop needs a darker theme, WSL needs a clipboard shim. Solution: a tracked, committed `init.lua` plus a pcall'd local override that's *not* tracked.

```lua
-- init.lua (committed)
pcall(function() require("local") end)
```

Then `~/.config/nvim/lua/local.lua` exists on some machines and not others. Similar trick for tmux (`~/.tmux.conf.local`) and bash (`~/.bashrc.local`).

---

## Appendix — Reading order for official docs

In roughly ascending specificity:

1. `:help nvim-quickstart`
2. `:help lua-guide` — the whole thing; 20 minutes, pays forever.
3. `:help options` + `:help option-summary`
4. `:help map-table` + `:help vim.keymap.set`
5. `:help autocmd`
6. `:help runtimepath` + `:help 'packpath'`
7. `:help lsp` (after you've touched at least one LSP)
8. `:help treesitter`
9. `:help api` — when you start writing plugins

---

## Appendix — External references worth bookmarking

- Official user docs — <https://neovim.io/doc/user/>
- Neovim news (per-release changelog in prose) — <https://neovim.io/doc/user/news.html>
- Lua guide — <https://neovim.io/doc/user/lua-guide.html>
- kickstart.nvim — <https://github.com/nvim-lua/kickstart.nvim>
- LazyVim (to lift patterns from, not to use as-is) — <https://www.lazyvim.org/>
- Awesome-neovim plugin catalog — <https://github.com/rockerBOO/awesome-neovim>
- TJ DeVries' Neovim YouTube channel — <https://www.youtube.com/@teej_dv>
- The Primeagen "0 to LSP" talk — <https://www.youtube.com/watch?v=w7i4amO_zaE> (slightly dated but the mental model still lands)
- Folke Lemaitre's blog (author of lazy.nvim, which-key, flash, snacks) — <https://folke.io/>

---

## TL;DR — one-paragraph recipe

Write `init.lua` that does nothing but `require` a handful of modules. Put options / keymaps / autocmds under `lua/config/`. Bootstrap a plugin manager and put one file per plugin under `lua/plugins/`. Use Neovim 0.11's `vim.lsp.config` + `lsp/<name>.lua` for LSP rather than writing a big inline block. Enable treesitter per-filetype with a `FileType` autocmd. Use `ftplugin/<lang>.lua` for small buffer-local settings. Keep a pcall'd `local.lua` for machine-specific overrides. When in doubt, `:help <topic>` before Googling — the docs are the source of truth, and Google results rot.
