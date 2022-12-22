(local km (require "nvlime.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))

(when (not (or vim.g.nvlime_disable_notes_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true false))
  (km.buffer.normal "<CR>"
                 "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote()<CR>"
                 "nvlime: Open the selected source location")
  (km.buffer.normal "<C-t>"
                 "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('tabedit')<CR>"
                 "nvlime: Open the selected source location in a new tabpage")
  (km.buffer.normal "<C-s>"
                 "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('split')<CR>"
                 "nvlime: Open the selected source location in a split")
  (km.buffer.normal "<C-v>"
                 "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('vsplit')<CR>"
                  "nvlime: Open the selected source location in a vertical split"))
