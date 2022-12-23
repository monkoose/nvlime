(local km (require "nvlime.keymaps"))
(local repl (require "nvlime.window.main.repl"))
(local km-globals (require "nvlime.keymaps.globals"))

(when (not (or vim.g.nvlime_disable_repl_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true false))
  (km.buffer.normal "<C-c>"
                    "<Cmd>call b:nvlime_conn.Interrupt({'name': 'REPL-THREAD', 'package': 'KEYWORD'})<CR>"
                    "nvlime: Interrupt the REPL thread")
  (km.buffer.normal "i"
                    "<Cmd>call nvlime#ui#repl#InspectCurREPLPresentation()<CR>"
                    "nvlime: Insect the evaluation result under the cursor")
  (km.buffer.normal "y"
                    "<Cmd>call nvlime#ui#repl#YankCurREPLPresentation()<CR>"
                    "nvlime: Yank the evaluation result under the cursor")
  (km.buffer.normal "C"
                    #(repl.clear)
                    "nvlime: Clear the REPL buffer")
  (km.buffer.normal "<Tab>"
                    "<Cmd>call nvlime#ui#repl#NextField(v:true)<CR>"
                    "nvlime: Move the cursor to the next presented object")
  (km.buffer.normal "<C-n>"
                    "<Cmd>call nvlime#ui#repl#NextField(v:true)<CR>"
                    "nvlime: Move the cursor to the next presented object")
  (km.buffer.normal "<S-Tab>"
                    "<Cmd>call nvlime#ui#repl#NextField(v:false)<CR>"
                    "nvlime: Move the cursor to the next presented object")
  (km.buffer.normal "<C-p>"
                    "<Cmd>call nvlime#ui#repl#NextField(v:false)<CR>"
                    "nvlime: Move the cursor to the next presented object"))
