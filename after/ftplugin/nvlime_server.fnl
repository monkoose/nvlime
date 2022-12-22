(local km (require "nvlime.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))

(when (not (or vim.g.nvlime_disable_server_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true true))
  (km.buffer.normal (.. km.leader "c")
                 "<Cmd>call nvlime#server#ConnectToCurServer()<CR>"
                 "nvlime: Connect to this server")
  (km.buffer.normal (.. km.leader "s")
                 "<Cmd>call nvlime#server#StopCurServer()<CR>"
                 "nvlime: Stop this server"))
