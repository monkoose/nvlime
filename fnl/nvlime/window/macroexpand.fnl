(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local macroexpand {})

(local +bufname+ (buffer.gen-name buffer.names.macroexpand))
(local +filetype+ (buffer.gen-filetype buffer.names.macroexpand))

;;; string -> [WinID BufNr]
(fn macroexpand.open [content]
  (let [bufnr (buffer.create-scratch
                +bufname+ +filetype+)]
    [(window.cursor.open
       bufnr (string.lower content)
       {:title buffer.names.macroexpand
        :similar ["nvlime_documentation"
                  "nvlime_description"]})
     bufnr]))

macroexpand
