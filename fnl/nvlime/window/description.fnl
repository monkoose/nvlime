(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local description {})

(local +bufname+ (buffer.gen-name buffer.names.description))
(local +filetype+ (buffer.gen-filetype buffer.names.description))

;;; string -> [WinID BufNr]
(fn description.open [content]
  (let [bufnr (buffer.create-scratch
                 +bufname+ +filetype+)]
    [(window.cursor.open
       bufnr content
       {:title buffer.names.description
        :similar ["nvlime_documentation"
                  "nvlime_macroexpand"]})
     bufnr]))

description
