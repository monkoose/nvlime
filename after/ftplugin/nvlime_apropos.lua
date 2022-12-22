local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_inspector_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  return km.buffer.normal("i", "<Cmd>call nvlime#plugin#Inspect(\"'\" .. substitute(getline('.'), '  .*$', '', ''))<CR>", "nvlime: Inspect current symbol")
else
  return nil
end