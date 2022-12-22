local km_globals = require("nvlime.keymaps.globals")
if not vim.g.nvlime_disable_mappings then
  if not vim.g.nvlime_disable_global_mappings then
    return km_globals.add(true, true)
  else
    return nil
  end
else
  return nil
end