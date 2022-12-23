(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local trace {})

(local +filetype+ (buffer.gen-filetype buffer.names.trace))

;;; ========== TRACE ==========
(fn trace.open [content config]
  (let [bufnr (buffer.create-scratch
                (buffer.gen-name
                  config.conn-name buffer.names.trace)
                +filetype+)]
    [(window.center.open
       bufnr content {:height 15
                      :width 80
                      :noedit true
                      :title "trace dialog"})
     bufnr]))

trace
