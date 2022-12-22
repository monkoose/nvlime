(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local threads {})

(local +name+ "threads")
(local +filetype+ (buffer.gen-filetype +name+))

;;; BufNr ->
(fn restrict-cursor [bufnr]
  (var prev-col 1)
  (fn restrict []
    (let [linenr (vim.fn.line ".")]
      (when (< linenr 3)
        (vim.fn.cursor 3 prev-col))
      (set prev-col (vim.fn.col "."))))
  (vim.api.nvim_create_autocmd
    "CursorMoved"
    {:buffer bufnr
     :callback #(restrict)}))

;;; WinID BufNr ->
(fn win-callback [winid bufnr]
  (window.set-opts winid {:cursorline true})
  (restrict-cursor bufnr))

;;; Plist {any} -> [WinID BufNr]
(fn threads.open [content config]
  (let [bufnr (buffer.create-scratch-with-conn-var!
                (buffer.gen-name
                  config.conn-name +name+)
                +filetype+)]
    [(window.center.open
       bufnr content
       {:height 10 :width 40 :title +name+}
       #(win-callback $1 $2))
     bufnr]))

threads
