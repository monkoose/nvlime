(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local documentation {})
(local +bufname+ (buffer.gen-name buffer.names.documentation))
(local +filetype+ (buffer.gen-filetype buffer.names.documentation))

;;; string -> [WinID BufNr]
(fn documentation.open [content]
  (let [bufnr (buffer.create-scratch
                +bufname+ +filetype+)]
    [(window.cursor.open
       bufnr content {:title buffer.names.documentation
                      :similar ["nvlime_description"
                                "nvlime_macroexpand"]})
     bufnr]))

documentation
