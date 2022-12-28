(local km (require "nvlime.keymaps"))
(local mm km.mappings.mrepl)

(local mrepl {})

(fn mrepl.add []
  (km.buffer.normal mm.normal.clear
                    "<Cmd>call nvlime#ui#mrepl#Clear()<CR>"
                    "nvlime: Clear the MREPL buffer")
  (km.buffer.normal mm.normal.disconnect
                    "<Cmd>call nvlime#ui#mrepl#Disconnect()<CR>"
                    "nvlime: Disconnect from this REPL")
  (km.buffer.insert mm.insert.space_arglist
                    "<Space><C-r>=nvlime#plugin#NvlimeKey('space')<CR>"
                    "nvlime: Trigger the arglist hint")
  (km.buffer.insert mm.insert.submit
                    "<C-r>=nvlime#ui#mrepl#Submit()<CR>"
                    "nvlime: Submit the last input to the REPL")
  (km.buffer.insert mm.insert.cr_arglist
                    "<CR><C-r>=nvlime#plugin#NvlimeKey('cr')<CR>"
                    "nvlime: Insert a newline and trigger the arglist hint")
  (km.buffer.insert mm.insert.interrupt
                    "<C-r>=nvlime#ui#mrepl#Interrupt()<CR>"
                    "nvlime: Interrupt the MREPL thread"))

mrepl
