# Neovim Configuration Improvement Suggestions

Review date: 2026-04-16

---

## 🔴 Bugs & Errors

### 1. Global variable leak in `options.lua`

**File:** `lua/config/options.lua`, line 7

```lua
-- Current (creates a global variable)
opt = vim.opt

-- Fix: use local
local opt = vim.opt
```

This leaks `opt` into the global Lua namespace, which can cause subtle conflicts
with plugins or other config files.

---

### 2. Conflicting `<A-j>` / `<A-k>` keymaps in normal mode

**File:** `lua/config/keymaps.lua`, lines 52–55 vs 85–90

Both "resize pane" and "move text" are mapped to `<A-j>` / `<A-k>` in normal
mode. The later mapping (move text) silently overwrites the earlier one (resize).

**Fix:** Pick one purpose per key, or use a different modifier for one set:

```lua
-- Option A: Use <C-A-j/k> for resize, <A-j/k> for move
-- Option B: Move resize to a leader-based key group
keymap("n", "<leader>w+", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<leader>w-", ":resize -2<CR>", { desc = "Decrease window height" })
```

---

### 3. Lua `or` expression bug in `bufferline.lua`

**File:** `lua/plugins/bufferline.lua`, line 11

```lua
-- Current: always evaluates to "slant" because Lua `or` returns first truthy value
separator_style = "slant" or "padded_slant",

-- Fix: pick one
separator_style = "slant",
```

This looks like an attempt to document alternatives, but in Lua `"slant" or
"padded_slant"` always evaluates to `"slant"`.

---

### 4. Wrong `copilot_filetypes` variable name

**File:** `lua/plugins/init.lua`, lines 5–10

```lua
-- Current: sets a meaningless global
vim.g.filetypes = { ... }

-- Fix: use the correct copilot variable
vim.g.copilot_filetypes = {
    python = true,
    sql = true,
    shell = true,
    ["*"] = false,
}
```

`vim.g.filetypes` has no effect on Copilot; the correct variable is
`vim.g.copilot_filetypes`.

---

### 5. Incorrect `desc` on blank-line keymaps

**File:** `lua/config/keymaps.lua`, lines 41–42

```lua
-- Current: both say "Paste below"
keymap("n", "]<Space>", "o<Esc>", { desc = "Paste below" })
keymap("n", "[<Space>", "O<Esc>", { desc = "Paste below" })

-- Fix:
keymap("n", "]<Space>", "o<Esc>", { desc = "Insert blank line below" })
keymap("n", "[<Space>", "O<Esc>", { desc = "Insert blank line above" })
```

---

### 6. Missing `claude-code.nvim` plugin declaration

**File:** `lua/config/keymaps.lua`, lines 120–121

Keymaps reference the `:ClaudeCode` command, but no plugin providing it
(e.g. `greggh/claude-code.nvim`) is declared in the plugin specs or present
in `lazy-lock.json`. These keymaps will silently fail.

**Fix:** Either add the plugin to your specs or remove the keymaps:

```lua
-- In a plugin spec file:
{
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
        { "<C-]>", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude Code", mode = { "n", "t" } },
    },
}
```

---

## 🟡 Deprecations

### 7. `vim.highlight.on_yank()` deprecated in Neovim 0.11+

**File:** `lua/config/autocmds.lua`, line 5

```lua
-- Deprecated
vim.highlight.on_yank()

-- Modern replacement (Neovim 0.11+)
vim.hl.on_yank()
```

`vim.highlight` was renamed to `vim.hl` in Neovim 0.11. The old name still
works but emits deprecation warnings.

---

### 8. `vim.api.nvim_set_keymap` usage in plugin files

**Files:** `lua/plugins/toggleterm.lua`, `lua/plugins/zk-nvim.lua`,
`lua/plugins/init.lua` (vim-markdown)

The older `vim.api.nvim_set_keymap` is still used in several places. The modern
`vim.keymap.set` API (already used in keymaps.lua) is preferred because:
- Accepts Lua functions directly
- Supports the `desc` field cleanly
- Supports buffer-local mappings via `{ buffer = ... }`

```lua
-- Old
vim.api.nvim_set_keymap("n", "<C-\\>", "<Cmd>ToggleTerm<CR>", opts)

-- Modern
vim.keymap.set("n", "<C-\\>", "<Cmd>ToggleTerm<CR>", { desc = "Terminal" })
```

---

### 9. `nvim-treesitter-locals` is archived/deprecated

**File:** `lua/plugins/treesitter.lua`, line 6

The `nvim-treesitter/nvim-treesitter-locals` plugin is archived. Its
functionality (highlight definitions, smart rename) has been superseded by
the main `nvim-treesitter` module and Neovim's built-in LSP features.

**Fix:** Remove the dependency and the `refactor` config block. Use LSP-based
rename (`vim.lsp.buf.rename`) instead of treesitter refactor's `smart_rename`.

---

### 10. Treesitter `smart_rename` keybinding `grr` conflicts with Neovim 0.11 built-in

**File:** `lua/plugins/treesitter.lua`, lines 41–46

Neovim 0.11 introduced `grr` as a built-in keymap for "go to references" (via
LSP). Your treesitter refactor config binds `grr` to `smart_rename`, which
shadows the built-in.

**Fix:** Remove the refactor config entirely (see point 9), or rebind to
something like `<leader>rr`.

---

### 11. `nvim-cmp` + `LuaSnip` → consider migrating to `blink.cmp`

**File:** `lua/plugins/init.lua`, lines 393–510

`hrsh7th/nvim-cmp` is in maintenance-only mode. The community is broadly
migrating to [`saghen/blink.cmp`](https://github.com/Saghen/blink.cmp), which
offers:
- Significantly faster performance (written in Rust)
- Built-in snippet support (no separate snippet engine needed)
- Simpler configuration
- Native LSP completion support

This is a larger migration but is worth planning as `nvim-cmp` will see fewer
updates over time.

---

### 12. `mason-lspconfig` `handlers` pattern is deprecated

**File:** `lua/plugins/init.lua`, lines 323–347

The `handlers = { ... }` pattern in `mason-lspconfig.setup()` is deprecated in
v2. The modern approach is:

```lua
require("mason-lspconfig").setup({
    ensure_installed = vim.tbl_keys(servers),
})

-- Set up servers directly
for server_name, server_opts in pairs(servers) do
    server_opts.capabilities = vim.tbl_deep_extend(
        "force", {}, capabilities, server_opts.capabilities or {}
    )
    require("lspconfig")[server_name].setup(server_opts)
end
```

---

## 🟢 Best Practices & Improvements

### 13. Remove debug code from production config

**Files:**
- `debug-vim-global.lua` — temporary debug script left in the config root
- `lua/plugins/init.lua`, lines 332–342 — `print("DEBUG: ...")` statements in
  the mason-lspconfig handler

These should be removed or gated behind a debug flag to avoid noisy output.

---

### 14. Shared `opts` table mutation in `keymaps.lua`

**File:** `lua/config/keymaps.lua`

The pattern of mutating a shared `opts` table (`opts.desc = "..."`) is fragile.
Since Lua tables are passed by reference, all previous keymaps sharing that same
`opts` table get their `desc` retroactively overwritten. This doesn't break
functionality but produces confusing which-key descriptions.

**Fix:** Use inline option tables:

```lua
keymap("n", "<leader>qb", ":bdel!<CR>", { noremap = true, silent = true, desc = "Quit buffer" })
keymap("n", "<leader>qa", ":bufdo bdel!<CR>", { noremap = true, silent = true, desc = "Quit all buffers" })
```

---

### 15. Add commonly expected keymaps

Several widely adopted keymaps are missing:

```lua
-- Clear search highlight on Escape (very common, almost universal)
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Quick save
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Diagnostic navigation (standard in most configs)
keymap("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
keymap("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })
```

Note: `vim.diagnostic.goto_prev/goto_next` are deprecated since Neovim 0.11;
use `vim.diagnostic.jump()` instead.

---

### 16. Enable diagnostic signs with Nerd Font icons

**File:** `lua/plugins/init.lua`, lines 238–245

The diagnostic signs configuration is commented out. Since `have_nerd_font` is
already set to `true`, enable it:

```lua
if vim.g.have_nerd_font then
    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '',
                [vim.diagnostic.severity.WARN] = '',
                [vim.diagnostic.severity.INFO] = '',
                [vim.diagnostic.severity.HINT] = '',
            },
        },
        virtual_text = { prefix = '●' },
        float = { border = 'rounded' },
    })
end
```

---

### 17. Configure `nvim-tree` icons dependency

**File:** `lua/plugins/nvim-tree.lua`

`nvim-tree.lua` should declare `nvim-tree/nvim-web-devicons` as a dependency
for proper file icons:

```lua
return {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { ... },
}
```

---

### 18. Telescope keymap uses string command instead of Lua function

**File:** `lua/plugins/telescope.lua`, lines 72–77

```lua
-- Current: uses a string command
vim.keymap.set("n", "<leader>fg",
    ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", ...)

-- Better: use a Lua function directly (cleaner, faster)
vim.keymap.set("n", "<leader>fg", function()
    require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "Search by Grep" })
```

---

### 19. Telescope desc labels are inconsistent with which-key group names

Telescope keymaps use `[S]earch` prefix in descriptions (e.g., `[S]earch
[F]iles`) but which-key defines the `<leader>f` group as `[f]ind`. Align them:

```lua
-- Either change which-key group to [s]earch:
{ "<leader>f", group = "[s]earch" },

-- Or change telescope descs to [F]ind:
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
```

---

### 20. Clean up the commented-out `avante.lua`

**File:** `lua/plugins/avante.lua`

The entire file is commented out. If avante is no longer needed, consider
deleting the file to reduce clutter. If it might return, add a brief comment
at the top explaining why it's disabled.

---

### 21. Add `vim.opt.termguicolors = true`

**File:** `lua/config/options.lua`

While many modern terminals auto-detect this, explicitly enabling
`termguicolors` ensures your Nord colorscheme renders correctly everywhere:

```lua
opt.termguicolors = true
```

---

## 📋 Summary

| Priority | Count | Description |
|----------|-------|-------------|
| 🔴 Bug | 6 | Global leak, keymap conflicts, Lua `or` bug, wrong var name, wrong desc, missing plugin |
| 🟡 Deprecated | 6 | `vim.highlight`, `nvim_set_keymap`, treesitter-locals, `grr` conflict, nvim-cmp, mason handlers |
| 🟢 Improvement | 9 | Debug cleanup, opts mutation, missing keymaps, diagnostic signs, icons dep, telescope cleanup, desc consistency, avante cleanup, termguicolors |
