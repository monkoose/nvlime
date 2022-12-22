local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_notes_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, false)
  else
  end
  km.buffer.normal("<CR>", "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote()<CR>", "nvlime: Open the selected source location")
  km.buffer.normal("<C-t>", "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('tabedit')<CR>", "nvlime: Open the selected source location in a new tabpage")
  km.buffer.normal("<C-s>", "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('split')<CR>", "nvlime: Open the selected source location in a split")
  return km.buffer.normal("<C-v>", "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('vsplit')<CR>", "nvlime: Open the selected source location in a vertical split")
else
  return nil
end