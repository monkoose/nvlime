(local keymaps
       {:leader (or vim.g.nvlime_leader
                    "<LocalLeader>")
        :buffer {}})

(fn from-keycode [key]
  (vim.api.nvim_replace_termcodes key true false true))

(fn keymaps.feedkeys [keys]
  (vim.api.nvim_feedkeys (from-keycode keys) "n" false))

(fn set-buf-map [mode lhs rhs desc]
  (let [opts {:noremap true
              :nowait true
              :silent true
              :desc desc}]
    (if (= (type rhs) "function")
      (do
        (tset opts :callback rhs)
        (vim.api.nvim_buf_set_keymap 0 mode lhs "" opts))
      (vim.api.nvim_buf_set_keymap 0 mode lhs rhs opts))))

(fn keymaps.buffer.normal [lhs rhs desc]
  (set-buf-map "n" lhs rhs desc))

(fn keymaps.buffer.insert [lhs rhs desc]
  (set-buf-map "i" lhs rhs desc))

(fn keymaps.buffer.visual [lhs rhs desc]
  (set-buf-map "v" lhs rhs desc))

(fn keymaps.buffer.get []
  (let [maps []]
    (each [_ mode (ipairs ["n" "i" "v"])]
      (icollect [_ map (ipairs (vim.api.nvim_buf_get_keymap 0 mode))
                   &into maps]
        (when (and map.desc (string.find map.desc "^nvlime:"))
          {:mode map.mode
           :lhs (string.gsub map.lhs " " "<SPACE>")
           :desc (string.gsub map.desc "^nvlime: " "")})))
    maps))

keymaps
