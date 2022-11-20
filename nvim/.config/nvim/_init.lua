local load = function(mod)
  package.loaded[mod] = nil
  require(mod)
end

load('user.options')
load('user.keymaps')
load('user.plugins')
load('user.plugin_keymap')
