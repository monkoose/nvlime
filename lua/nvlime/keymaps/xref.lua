local km = require("nvlime.keymaps")
local xm = km.mappings.xref
local xref = {}
xref.add = function()
  km.buffer.normal(xm.normal.source, "<Cmd>call nvlime#ui#xref#OpenCurXref()<CR>", "nvlime: Open the selected source location")
  km.buffer.normal(xm.normal.source_split, "<Cmd>call nvlime#ui#xref#OpenCurXref('split')<CR>", "nvlime: Open the selected source location in a split")
  km.buffer.normal(xm.normal.source_vsplit, "<Cmd>call nvlime#ui#xref#OpenCurXref('vsplit')<CR>", "nvlime: Open the selected source location in a vertical split")
  return km.buffer.normal(xm.normal.source_tab, "<Cmd>call nvlime#ui#xref#OpenCurXref('tabedit')<CR>", "nvlime: Open the selected source location in a new tabpage")
end
return xref