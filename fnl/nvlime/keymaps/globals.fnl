(local window (require "nvlime.window"))
(local km (require "nvlime.keymaps"))
(local km-window (require "nvlime.window.keymaps"))

(local globals {})

(local +scroll-step+ (or vim.g.nvlime_scroll_step 3))
(local +scroll-up+ (or vim.g.nvlime_scroll_up "<C-p>"))
(local +scroll-down+ (or vim.g.nvlime_scroll_down "<C-n>"))

(fn split-focus [cmd key]
  (km.buffer.normal key
                    #(when (window.split_focus cmd)
                       (vim.api.nvim_buf_del_keymap 0 "n" "<C-w>h")
                       (vim.api.nvim_buf_del_keymap 0 "n" "<C-w>l")
                       (vim.api.nvim_buf_del_keymap 0 "n" "<C-w>k")
                       (vim.api.nvim_buf_del_keymap 0 "n" "<C-w>j"))
                    "Split into last non-floating window"))

;;; bool ->
(fn globals.add [add-close? add-split?]
  (when add-close?
    (km.buffer.normal "q"
                      #(vim.api.nvim_win_close 0 true)
                      "Close current window"))
  (km.buffer.normal (.. km.leader "?")
                    #(km-window.toggle)
                    "Show keymaps help")
  (km.buffer.normal "<F1>"
                    #(km-window.toggle)
                    "Show keymaps help")
  (km.buffer.normal (.. km.leader "ww")
                    #(window.close_all_except_main)
                    "Close all nvlime windows except main ones")
  (km.buffer.normal "<Esc>"
                    #(when (not (window.close_last_float))
                       (km.feedkeys "<Esc>"))
                    "Close last opened floating window")
  (km.buffer.normal +scroll-up+
                    #(when (not (window.scroll_float +scroll-step+ true))
                       (km.feedkeys +scroll-up+))
                    "Scroll up last opened floating window")
  (km.buffer.normal +scroll-down+
                    #(when (not (window.scroll_float +scroll-step+))
                       (km.feedkeys +scroll-down+))
                    "Scroll down last opened floating window")
  (when add-split?
    (split-focus "vertical leftabove split" "<C-w>h")
    (split-focus "vertical rightbelow split" "<C-w>l")
    (split-focus "leftabove split" "<C-w>k")
    (split-focus "rightbelow split" "<C-w>j")))

globals
