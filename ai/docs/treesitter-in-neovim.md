# Treesitter in Neovim

A primer on what tree-sitter is, what Neovim ships built-in, where the `nvim-treesitter` plugin fits, and how downstream plugins build on the stack. Written after hitting a real `Invalid field name "operator"` query error in this repo and tracing through the moving parts — this doc is the mental model that would have short-circuited that debugging.

---

## 1. What tree-sitter is (the upstream library)

[tree-sitter](https://tree-sitter.github.io/) is a **parser generator and incremental parsing library** written in C, maintained by GitHub. It is not Neovim-specific; Atom, Helix, Zed, GitHub's code search, and many others use it.

Three pieces to keep separate in your head:

- **tree-sitter (the library)** — C library that, given a parser and a source buffer, produces a concrete syntax tree (CST) and keeps it up to date on every edit. It is *incremental* — re-parsing after a keystroke is O(edit size), not O(buffer size).
- **A grammar** — a declarative description of a language's syntax, written in JavaScript (`grammar.js`). Living example: [`tree-sitter-python`](https://github.com/tree-sitter/tree-sitter-python).
- **A parser** — the compiled artifact (`src/parser.c` generated from the grammar, then compiled to `.so` / `.dylib` / `.dll`). This is what actually runs at edit time. Named per-language: `lua.so`, `python.so`, `markdown.so`.

Grammars are compiled using the **tree-sitter CLI** (`tree-sitter` binary — Rust). The CLI is how parsers get generated from `grammar.js` and then compiled into shared libraries.

A parse tree has two kinds of relationships:

- **Children** — positional, ordered. Traversable by index.
- **Fields** — named, optional. e.g. an `assignment` node may expose a `left:` and `right:` field pointing to specific children.

Fields are important: queries (see below) can match on either children or fields. When a grammar is revised, field names can be added, renamed, or removed — that's the exact shape of the mismatch that caused the earlier `operator` error.

---

## 2. What Neovim 0.9+ ships built-in

Neovim embedded the tree-sitter C library directly. From 0.9 onward, treesitter is a first-class engine exposed under `vim.treesitter.*`. No plugin required to use it.

### Runtime layout

```
/usr/share/nvim/runtime/
├── parser/<lang>.so           -- bundled compiled parsers (a small curated set)
├── queries/<lang>/*.scm       -- bundled queries (highlights, folds, indents, injections, locals)
├── ftplugin/<lang>.lua        -- per-filetype hooks; some call vim.treesitter.start()
└── lua/vim/treesitter/*.lua   -- the Lua API surface
```

Bundled parsers as of Neovim 0.12: `c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`. Everything else is your problem to install.

### The `vim.treesitter.*` API surface (most-touched)

- `vim.treesitter.start(bufnr?, lang?)` — attach the highlighter to a buffer.
- `vim.treesitter.stop(bufnr?)` — detach.
- `vim.treesitter.get_parser(bufnr, lang?)` — the parser object; yields a `TSTree`.
- `vim.treesitter.query.parse(lang, scm_string)` — compile a query.
- `vim.treesitter.foldexpr()` — a ready-to-use fold expression. Plug into `&foldexpr`.
- `vim.treesitter.language.add(lang, opts?)` — register a parser by filename or path.
- `vim.treesitter.language.register(parser_lang, filetypes)` — map a parser to additional filetypes (e.g. `register('bash', { 'zsh' })`).
- `vim.treesitter.highlighter.active[bufnr]` — inspect whether a buffer is being highlighted.

### Queries

Queries are written in a [Scheme-like S-expression DSL](https://tree-sitter.github.io/tree-sitter/using-parsers#pattern-matching-with-queries), saved as `.scm` files under `queries/<lang>/`. Neovim recognizes five conventional query files per language:

| File | Purpose |
|---|---|
| `highlights.scm` | Map node patterns to capture names like `@keyword`, `@function`, `@string`. Neovim turns captures into `:h group-name` highlight groups (`@keyword` → `@keyword.lua` → linked to `Keyword`). |
| `injections.scm` | Tell the parser that a region of *this* language is really *another* language. Example: `lua` fenced code inside markdown. This is how the markdown file that triggered the earlier bug ended up running the `lua` query — the `markdown_inline` parser *injected* lua into the fenced region. |
| `folds.scm` | Nodes whose ranges define fold regions. Consumed by `vim.treesitter.foldexpr()`. |
| `indents.scm` | Nodes that influence indentation (experimental, plugin-provided — see below). |
| `locals.scm` | Scope/definition/reference analysis. Used by refactor-style features. |

A query like

```scheme
(binary_expression
  operator: _ @operator)
```

captures the node referenced by the `operator:` field of any `binary_expression` under the capture name `@operator`. If a later grammar revision removes the `operator:` field, query compilation fails with *"Invalid field name 'operator'"* — exactly the error that started this thread.

### How highlighting actually turns on

Neovim does **not** auto-enable treesitter for every filetype with an installed parser. The on-switch is `vim.treesitter.start()`. Three ways it gets called in practice:

1. **A shipped `ftplugin/<lang>.lua`** — Neovim's bundled ftplugins for `lua`, `markdown`, `query`, `help` (and a handful of others) call `vim.treesitter.start()`. That's why those filetypes "just work" even with an empty config.
2. **Your own `FileType` autocmd** — the idiomatic place to enable it for languages Neovim doesn't ship an ftplugin for. This repo does this in `nvim/.config/nvim/lua/plugins/treesitter.lua`.
3. **A plugin** — historically, nvim-treesitter's old `master` branch auto-enabled it when you passed `highlight = { enable = true }`. The new `main` branch does not; you have to call `vim.treesitter.start()` yourself.

---

## 3. Where `nvim-treesitter` (the plugin) fits

nvim-treesitter has two distinct lives:

### Old `master` branch (Neovim ≤ 0.10 era)

One plugin, all the batteries: installer, parsers, queries, *modules* (`highlight`, `indent`, `incremental_selection`, `textobjects`, `refactor`). You called `setup({ highlight = { enable = true }, ... })` and it wired everything up.

Still maintained for backwards compatibility, but frozen feature-wise.

### New `main` branch (v1.0 rewrite, Neovim 0.11+)

A deliberately narrower plugin:

1. **Parser installer / updater.** `:TSInstall`, `:TSUpdate`, `:TSUninstall`. Requires a system-installed `tree-sitter` CLI (≥ 0.26.1); it downloads grammar repos, runs `tree-sitter generate`, compiles the `.so`, and drops it under `stdpath("data") .. "/site/parser/"`.
2. **Query collection.** A curated `queries/<lang>/` tree for languages whose upstream doesn't ship Neovim-friendly queries.
3. **Staging ground for experimental features** (e.g. `indentexpr()`).

What it no longer does:
- No more `highlight`, `indent`, `incremental_selection`, `textobjects`, `refactor` modules.
- Those features either moved into Neovim core (`highlight`, `foldexpr`), spun into separate plugins (`nvim-treesitter-textobjects`, `nvim-treesitter-locals`), or are provided as one-liner helpers you wire into `ftplugin` / autocmds yourself.

Key consequence: the `setup({ ensure_installed, auto_install, highlight, indent, ... })` API from the `master` branch is **silently ignored** on `main`. This was exactly the shape of the bug in `plugins/treesitter.lua` before the fix — options passing through a no-op `setup`.

### New-API cheatsheet

```lua
require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
require("nvim-treesitter").install({ "python", "bash", "lua" })       -- async, idempotent
require("nvim-treesitter").install({ ... }):wait(300000)               -- sync variant
```

Enable features per filetype yourself:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "bash", "lua" },
  callback = function(args)
    vim.treesitter.start(args.buf)
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr   = "v:lua.vim.treesitter.foldexpr()"
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

### Parser resolution order

Neovim searches every `runtimepath` entry for `parser/<lang>.so` and loads the **first hit**. nvim-treesitter's `install_dir` is prepended to the runtimepath, so a parser installed by the plugin wins over Neovim's bundled one.

This ordering is the other half of the earlier bug: a stale `nvim-treesitter`-installed `lua.so` shadowed Neovim's bundled `lua.so`. Deleting the stale file made Neovim's own win. If you want the inverse — force Neovim to prefer its bundled parser over a plugin-installed one — either `:TSUninstall <lang>` or manipulate the runtimepath order.

---

## 4. The surrounding plugin ecosystem

Treesitter is a **substrate**, not an end product. Plugins compose on top of it. Popular ones:

| Plugin | Role |
|---|---|
| `nvim-treesitter/nvim-treesitter-textobjects` | Adds `af` / `if` / `ac` / `ic` / `aa` / `ia` (around/inside function, class, parameter). The single highest-ROI addon for most users. |
| `nvim-treesitter/nvim-treesitter-context` | Sticky header showing the enclosing function / class / block as you scroll. |
| `nvim-treesitter/nvim-treesitter-locals` | Rename / goto-definition / references using `locals.scm` — replaces the old `refactor` module from the `master` branch. |
| `RRethy/nvim-treesitter-endwise` | Auto-insert `end` / closing tags for languages where that makes sense (Lua, Ruby, Bash). |
| `HiPhish/rainbow-delimiters.nvim` | Rainbow parens using tree-sitter nodes instead of regex. |
| `MeanderingProgrammer/render-markdown.nvim`, `lukas-reineke/headlines.nvim` | Prettify markdown buffers using the markdown tree. |
| `windwp/nvim-ts-autotag` | Auto-close JSX/HTML tags via tree-sitter. |

Non-plugin consumers inside Neovim:

- **LSP semantic tokens** layer on top of treesitter highlights (treesitter runs first; LSP semantic tokens refine).
- **Diagnostics rendering** (`vim.diagnostic`) is independent of treesitter, but diagnostics referring to LSP positions are interpreted against treesitter-parsed source.
- **`:InspectTree`** — built-in command to view the live parse tree for the current buffer. Indispensable when writing or debugging queries.
- **`:Inspect`** — under the cursor, show which highlight captures / LSP tokens apply. The single best tool for answering "why is this word the wrong color?".

---

## 5. Practical commands you'll actually type

```
:InspectTree                        -- visualize the CST of the current buffer
:Inspect                            -- show captures + links at cursor
:TSInstall <lang>                   -- install a parser
:TSUpdate [<lang>]                  -- update parsers to the version pinned by the plugin's lockfile
:TSUninstall <lang>                 -- remove a plugin-installed parser
:checkhealth vim.treesitter         -- runtime health; flags broken parsers / queries
:checkhealth nvim-treesitter        -- plugin health; lists what's installed and where
```

In Lua, when debugging:

```lua
-- Which parsers are installed (main branch):
:lua = require("nvim-treesitter.config").get_installed()

-- Is treesitter highlighting *this* buffer?
:lua = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil

-- Where did a parser come from?
:lua = vim.api.nvim_get_runtime_file("parser/lua.so", true)
```

---

## 6. Troubleshooting flow (the one you'll actually need)

When treesitter misbehaves, work top-down:

1. **Is highlighting on at all?** `:Inspect` at the cursor. If empty, `vim.treesitter.start()` was never called — check that an ftplugin or your autocmd fires for this filetype.
2. **Is there a parser?** `:lua = vim.api.nvim_get_runtime_file("parser/<lang>.so", true)` — expect at least one path. Empty ⇒ install the parser (requires `tree-sitter` CLI on the new main branch).
3. **Is there a query error?** `:checkhealth vim.treesitter` — the message is verbatim the one from the decoration provider.
4. **Parser ↔ query mismatch** — the exact shape of the earlier bug. Symptom: a query file references a field or node name the installed parser doesn't have. Resolution: either update the parser to a version matching the query (`:TSUpdate <lang>`, possibly after `:Lazy update nvim-treesitter` to bump the lockfile pin) or delete the stale plugin-installed parser so Neovim's bundled one wins.
5. **Injections look wrong** — e.g. lua inside markdown doesn't highlight. `:InspectTree` on the markdown buffer will show whether the injection ranges are being recognized. Missing injection usually means `markdown_inline`'s `injections.scm` isn't finding your fence language, or the injected parser isn't installed.

---

## 7. TL;DR for this repo

- Neovim 0.12 is the treesitter runtime; `vim.treesitter.*` is the API.
- `nvim-treesitter` on `main` is now only an installer / query provider — it does *not* enable highlighting for you.
- Our `plugins/treesitter.lua` explicitly calls `vim.treesitter.start()` / sets `foldexpr` / sets `indentexpr` in a `FileType` autocmd for the parsers we care about.
- Parser installs are gated on `tree-sitter` being in `PATH`; without the CLI, we fall back to Neovim's bundled parsers (`c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`).
- When something goes weird, the four tools are: `:InspectTree`, `:Inspect`, `:checkhealth vim.treesitter`, and checking parser resolution with `vim.api.nvim_get_runtime_file("parser/<lang>.so", true)`.
