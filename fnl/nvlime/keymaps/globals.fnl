(local window (require "nvlime.window"))
(local km (require "nvlime.keymaps"))
(local gm km.mappings.global)
(local km-window (require "nvlime.window.keymaps"))
(local psl (require "parsley"))
(local opts (require "nvlime.config"))
(local {: nvim_win_close
        : nvim_buf_del_keymap}
       vim.api)

(local globals {})

(fn del-buffer-keymaps [bufnr mode maps]
  (each [_ map (ipairs maps)]
    (pcall nvim_buf_del_keymap bufnr mode map)))

(local split-keys [])
(each [_ keys (ipairs [gm.normal.slit_left
                       gm.normal.split_right
                       gm.normal.split_above
                       gm.normal.split_below])]
  (if (psl.string? keys)
      (table.insert split-keys keys)
      (icollect [_ key (ipairs keys) &into split-keys]
        key)))

(fn split-focus [cmd key]
  (km.buffer.normal key
                    #(when (window.split_focus cmd)
                       (del-buffer-keymaps 0 "n" split-keys))
                    "Split into last non-floating window"))

;;; bool ->
(fn globals.add [add-close? add-split?]
  (when add-close?
    (km.buffer.normal gm.normal.close_current_window
                      #(nvim_win_close 0 true)
                      "Close current window"))
  (km.buffer.normal gm.normal.keymaps_help
                    #(km-window.toggle)
                    "Show keymaps help")
  (km.buffer.normal gm.normal.close_nvlime_windows
                    #(window.close_all_except_main)
                    "Close all nvlime windows except main ones")
  (km.buffer.normal gm.normal.close_floating_window
                    #(when (not (window.close_last_float))
                       (km.feedkeys "<Esc>"))
                    "Close last opened floating window")
  (km.buffer.normal gm.normal.scroll_up
                    #(when (not (window.scroll_float
                                  opts.floating_window.scroll_step true))
                       (km.feedkeys gm.normal.scroll_up))
                    "Scroll up last opened floating window")
  (km.buffer.normal gm.normal.scroll_down
                    #(when (not (window.scroll_float
                                  opts.floating_window.scroll_step))
                       (km.feedkeys gm.normal.scroll_down))
                    "Scroll down last opened floating window")
  (when add-split?
    (split-focus "vertical leftabove split" gm.normal.split_left)
    (split-focus "vertical rightbelow split" gm.normal.split_right)
    (split-focus "leftabove split" gm.normal.split_above)
    (split-focus "rightbelow split" gm.normal.split_below)))

globals
