-- Temporary debug script to check lua_ls configuration
-- Run this in Neovim with :luafile %

print("=== Debugging vim global warning ===\n")

-- Check if lazydev is loaded
local lazydev_ok, lazydev = pcall(require, "lazydev")
print("1. lazydev loaded: " .. tostring(lazydev_ok))

-- Check active LSP clients
local clients = vim.lsp.get_clients({ bufnr = 0 })
print("\n2. Active LSP clients for this buffer:")
for _, client in ipairs(clients) do
    print("   - " .. client.name)
    if client.name == "lua_ls" then
        print("     Config workspace library:")
        if client.config.settings and client.config.settings.Lua then
            local lua_config = client.config.settings.Lua
            if lua_config.workspace and lua_config.workspace.library then
                for _, lib in ipairs(lua_config.workspace.library) do
                    print("       * " .. lib)
                end
            end
            if lua_config.diagnostics and lua_config.diagnostics.globals then
                print("     Diagnostics globals:")
                for _, global in ipairs(lua_config.diagnostics.globals) do
                    print("       * " .. global)
                end
            end
        end
    end
end

print("\n3. To fix the warning, restart lua_ls:")
print("   :LspRestart lua_ls")
print("\nOr restart Neovim completely")
