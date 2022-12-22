local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_xref_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  km.buffer.normal("<CR>", "<Cmd>call nvlime#ui#xref#OpenCurXref()<CR>", "nvlime: Open the selected source location")
  km.buffer.normal("<C-t>", "<Cmd>call nvlime#ui#xref#OpenCurXref('tabedit')<CR>", "nvlime: Open the selected source location in a new tabpage")
  km.buffer.normal("<C-s>", "<Cmd>call nvlime#ui#xref#OpenCurXref('split')<CR>", "nvlime: Open the selected source location in a split")
  return km.buffer.normal("<C-v>", "<Cmd>call nvlime#ui#xref#OpenCurXref('vsplit')<CR>", "nvlime: Open the selected source location in a vertical split")
else
  return nil
end