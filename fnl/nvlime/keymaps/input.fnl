(local km (require "nvlime.keymaps"))
(local im km.mappings.input)
(local km-window (require "nvlime.window.keymaps"))

(local input {})

(fn input.add []
  (km.buffer.normal im.normal.complete
                    "<Cmd>call nvlime#ui#input#FromBufferComplete()<CR>"
                    "nvlime: Complete the input")
  (km.buffer.insert im.insert.keymaps_help
                    #(km-window.toggle)
                    "Show keymaps help")
  (km.buffer.insert im.insert.complete
                    "<Cmd>call nvlime#ui#input#FromBufferComplete()<CR>"
                    "nvlime: Complete the input")
  (km.buffer.insert im.insert.next_history
                    "<Cmd>call nvlime#ui#input#NextHistoryItem()<CR>"
                    "nvlime: Show the next item in input history")
  (km.buffer.insert im.insert.prev_history
                    "<Cmd>call nvlime#ui#input#NextHistoryItem(v:false)<CR>"
                    "nvlime: Show the previous item in input history")
  (km.buffer.insert im.insert.leave_insert
                    #(let [[linenr col] (vim.api.nvim_win_get_cursor 0)]
                       (if (and (= linenr 1) (= col 0))
                           (vim.api.nvim_win_close 0 true))
                       (km.feedkeys "<Esc>"))
                    "Close window or leave insert mode"))

input
