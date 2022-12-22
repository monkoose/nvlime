(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))
(local km (require "nvlime.keymaps"))
(local ut (require "nvlime.utilities"))
(local psl-buf (require "parsley.buffer"))
(local psl-win (require "parsley.window"))

(local input {})

(local +name+ "input")
(local +namespace+ (vim.api.nvim_create_namespace
                     (buffer.gen-filetype +name+)))

;;; {any} -> {any}
(fn calc-opts [config]
  (let [border-len 2
        wininfo (psl-win.get-info
                  (vim.api.nvim_get_current_win))
        width (math.min 80 (- wininfo.width
                              wininfo.textoff
                              border-len))
        height 4
        row (- wininfo.height height border-len)]
    {:relative "win"
     :row row
     :col wininfo.textoff
     :width width
     :height height
     :title config.prompt
     :title_pos "center"}))

;;; BufNr {any} ->
(fn buf-callback [bufnr]
  (buffer.set-conn-var! bufnr)
  (buffer.set-vars bufnr {:nvlime_input true})
  (buffer.set-opts
    bufnr {:filetype "lisp"
           :bufhidden "wipe"
           :modifiable true}))

;;; ->
(fn win-callback []
  (km.feedkeys "a"))

;;; string -> [any]
(fn text->virt-lines [str]
  (let [lines (ut.text->lines str)]
    (icollect [_ line (ipairs lines)]
      [[line "Comment"]])))

;;; BufNr ->
(fn show-history-extmark [bufnr]
  (var extmark-id 0)
  (let [history-len (length vim.g.nvlime_input_history)
        group (vim.api.nvim_create_augroup
                "nvlime-input-history" {})
        add-extmark
        (fn []
          (vim.api.nvim_buf_clear_namespace
            bufnr +namespace+ 0 -1)
          (set extmark-id
               (vim.api.nvim_buf_set_extmark
                 bufnr +namespace+ 0 0
                 {:virt_lines
                  (text->virt-lines
                    (. vim.g.nvlime_input_history history-len))})))]
    (vim.api.nvim_create_autocmd
      ["CursorMoved" "CursorMovedI"]
      {:group group
       :buffer bufnr
       :callback #(if (and (psl-buf.empty? bufnr)
                           (> history-len 0))
                      (add-extmark)
                      (vim.api.nvim_buf_clear_namespace
                        bufnr +namespace+ 0 -1))})))

;;; string {any} -> [WinID BufNr]
(fn input.open [content config]
  (let [lines (ut.text->lines content)
        bufnr (buffer.create-if-not-exists
                (buffer.gen-name config.conn-name
                                 +name+
                                 config.prompt)
                false
                #(buf-callback $))
        opts (calc-opts config)]
    (show-history-extmark bufnr)
    (buffer.fill! bufnr lines)
    (let [winid (window.open-float
                  bufnr opts true true
                  #(win-callback))]
      [winid bufnr])))

input
