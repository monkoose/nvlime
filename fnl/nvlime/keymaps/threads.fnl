(local km (require "nvlime.keymaps"))
(local tm km.mappings.threads)

(local threads {})

(fn threads.add []
  (km.buffer.normal tm.normal.interrupt
                    "<Cmd>call nvlime#ui#threads#InterruptCurThread()<CR>"
                    "nvlime: Interrupt the selected thread")
  (km.buffer.normal tm.normal.kill
                    "<Cmd>call nvlime#ui#threads#KillCurThread()<CR>"
                    "nvlime: Kill the selected thread")
  (km.buffer.normal tm.normal.invoke_debugger
                    "<Cmd>call nvlime#ui#threads#DebugCurThread()<CR>"
                    "nvlime: Invoke the debugger in the selected thread")
  (km.buffer.normal tm.normal.refresh
                    "<Cmd>call nvlime#ui#threads#Refresh()<CR>"
                    "nvlime: Refresh the thread list"))

threads
