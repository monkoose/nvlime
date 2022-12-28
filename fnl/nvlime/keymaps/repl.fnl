(local km (require "nvlime.keymaps"))
(local rm km.mappings.repl)

(local repl {})

(fn repl.add []
  (km.buffer.normal rm.normal.interrupt
                    "<Cmd>call b:nvlime_conn.Interrupt({'name': 'REPL-THREAD', 'package': 'KEYWORD'})<CR>"
                    "nvlime: Interrupt the REPL thread")
  (km.buffer.normal rm.normal.clear
                    #(repl.clear)
                    "nvlime: Clear the REPL buffer")
  (km.buffer.normal rm.normal.inspect_result
                    "<Cmd>call nvlime#ui#repl#InspectCurREPLPresentation()<CR>"
                    "nvlime: Insect the evaluation result under the cursor")
  (km.buffer.normal rm.normal.yank_result
                    "<Cmd>call nvlime#ui#repl#YankCurREPLPresentation()<CR>"
                    "nvlime: Yank the evaluation result under the cursor")
  (km.buffer.normal rm.normal.next_result
                    "<Cmd>call nvlime#ui#repl#NextField(v:true)<CR>"
                    "nvlime: Move the cursor to the next presented object")
  (km.buffer.normal rm.normal.prev_result
                    "<Cmd>call nvlime#ui#repl#NextField(v:false)<CR>"
                    "nvlime: Move the cursor to the next presented object"))

repl
