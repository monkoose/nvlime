(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))
(local {: nvim_create_autocmd}
       vim.api)

(local threads {})

(local +filetype+ (buffer.gen-filetype buffer.names.threads))

;;; BufNr ->
(fn restrict-cursor [bufnr]
  (var prev-col 1)
  (fn restrict []
    (let [linenr (vim.fn.line ".")]
      (when (< linenr 3)
        (vim.fn.cursor 3 prev-col))
      (set prev-col (vim.fn.col "."))))
  (nvim_create_autocmd "CursorMoved"
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
                  config.conn-name buffer.names.threads)
                +filetype+)]
    [(window.center.open
       bufnr content
       {:height 10 :width 40 :title buffer.names.threads}
       #(win-callback $1 $2))
     bufnr]))

threads
