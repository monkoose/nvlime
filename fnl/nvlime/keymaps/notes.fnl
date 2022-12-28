(local km (require "nvlime.keymaps"))
(local nm km.mappings.notes)

(local notes {})

(fn notes.add []
  (km.buffer.normal nm.normal.source
                    "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote()<CR>"
                    "nvlime: Open the selected source location")
  (km.buffer.normal nm.normal.source_split
                    "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('split')<CR>"
                    "nvlime: Open the selected source location in a split")
  (km.buffer.normal nm.normal.source_vsplit
                    "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('vsplit')<CR>"
                    "nvlime: Open the selected source location in a vertical split")
  (km.buffer.normal nm.normal.source_tab
                    "<Cmd>call nvlime#ui#compiler_notes#OpenCurNote('tabedit')<CR>"
                    "nvlime: Open the selected source location in a new tabpage"))

notes
