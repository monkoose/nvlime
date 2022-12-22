(local km (require "nvlime.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))

(when (not (or vim.g.nvlime_disable_mrepl_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true true))
  (km.buffer.insert "<Space>"
                 "<Space><C-r>=nvlime#plugin#NvlimeKey('space')<CR>"
                 "nvlime: Trigger the arglist hint")
  (km.buffer.insert "<CR>"
                 "<C-r>=nvlime#ui#mrepl#Submit()<CR>"
                 "nvlime: Submit the last input to the REPL")
  (km.buffer.insert "<C-j>
                 " "<CR><C-r>=nvlime#plugin#NvlimeKey('cr')<CR>"
                 "nvlime: Insert a newline and trigger the arglist hint")
  (km.buffer.insert "<Tab>
                 " "<C-r>=nvlime#plugin#NvlimeKey('tab')<CR>"
                 "nvlime: Trigger omni-completion")
  (km.buffer.insert "<C-c>
                 " "<C-r>=nvlime#ui#mrepl#Interrupt()<CR>"
                 "nvlime: Interrupt the MREPL thread")
  (km.buffer.normal (.. km.leader "C")
                 "<Cmd>call nvlime#ui#mrepl#Clear()<CR>"
                 "nvlime: Clear the MREPL buffer")
  (km.buffer.normal (.. km.leader "D")
                 "<Cmd>call nvlime#ui#mrepl#Disconnect()<CR>"
                 "nvlime: Disconnect from this REPL"))
