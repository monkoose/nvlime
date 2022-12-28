(local km-globals (require "nvlime.keymaps.globals"))
(local km-input (require "nvlime.keymaps.input"))
(local km-lisp (require "nvlime.keymaps.lisp"))

;; So that indentexpr is actually used
(vim.api.nvim_buf_set_option 0 "lisp" false)
(vim.cmd "syntax match SpellIgnore /\\<u\\+\\>/ contains=@NoSpell")

(if vim.b.nvlime_input
    (do  ; input buffers
      (km-globals.add true true)
      (km-input.add))
    (do  ; lisp buffers
      (km-globals.add false false)
      (km-lisp.add)))
