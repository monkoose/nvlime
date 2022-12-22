(local km (require "nvlime.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))

(when (not (or vim.g.nvlime_disable_xref_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true true))
  (km.buffer.normal "<CR>"
                 "<Cmd>call nvlime#ui#xref#OpenCurXref()<CR>"
                  "nvlime: Open the selected source location")
  (km.buffer.normal "<C-t>"
                 "<Cmd>call nvlime#ui#xref#OpenCurXref('tabedit')<CR>"
                  "nvlime: Open the selected source location in a new tabpage")
  (km.buffer.normal "<C-s>"
                 "<Cmd>call nvlime#ui#xref#OpenCurXref('split')<CR>"
                  "nvlime: Open the selected source location in a split")
  (km.buffer.normal "<C-v>"
                 "<Cmd>call nvlime#ui#xref#OpenCurXref('vsplit')<CR>"
                  "nvlime: Open the selected source location in a vertical split"))
