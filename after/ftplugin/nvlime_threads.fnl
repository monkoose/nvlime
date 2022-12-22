(local km (require "nvlime.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))

(when (not (or vim.g.nvlime_disable_threads_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true true))
  (km.buffer.normal "<C-c>"
                 "<Cmd>call nvlime#ui#threads#InterruptCurThread()<CR>"
                 "nvlime: Interrupt the selected thread")
  (km.buffer.normal "K"
                 "<Cmd>call nvlime#ui#threads#KillCurThread()<CR>"
                 "nvlime: Kill the selected thread")
  (km.buffer.normal "D"
                 "<Cmd>call nvlime#ui#threads#DebugCurThread()<CR>"
                 "nvlime: Invoke the debugger in the selected thread")
  (km.buffer.normal "r"
                 "<Cmd>call nvlime#ui#threads#Refresh()<CR>"
                  "nvlime: Refresh the thread list"))
