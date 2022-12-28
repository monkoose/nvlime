(local km (require "nvlime.keymaps"))
(local tm km.mappings.trace)

(local trace {})

(fn trace.add []
  (km.buffer.normal tm.normal.action
                    "<Cmd>call nvlime#ui#trace_dialog#Select()<CR>"
                    "nvlime: Activate the interactable field/button under the cursor")
  (km.buffer.normal tm.normal.refresh
                    "<Cmd>call nvlime#plugin#OpenTraceDialog()<CR>"
                    "nvlime: Refresh the trace dialog")
  (km.buffer.normal tm.normal.inspect_value
                    "<Cmd>call nvlime#ui#trace_dialog#Select('inspect')<CR>"
                    "nvlime: Inspect the value of the field under the cursor")
  (km.buffer.normal tm.normal.send_value
                    "<Cmd>call nvlime#ui#trace_dialog#Select('to_repl')<CR>"
                    "nvlime: Send the value of the field under the cursor to the REPL")
  (km.buffer.normal tm.normal.next_field
                    "<Cmd>call nvlime#ui#trace_dialog#NextField(v:true)<CR>"
                    "nvlime: Select the next interactable field/button")
  (km.buffer.normal tm.normal.prev_field
                    "<Cmd>call nvlime#ui#trace_dialog#NextField(v:false)<CR>"
                    "nvlime: Select the previous interactable field/button"))

trace
