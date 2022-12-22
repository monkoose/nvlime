(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local macroexpand {})

(local +name+ "macroexpand")
(local +bufname+ (buffer.gen-name +name+))
(local +filetype+ (buffer.gen-filetype +name+))

;;; string -> [WinID BufNr]
(fn macroexpand.open [content]
  (let [bufnr (buffer.create-scratch
                +bufname+ +filetype+)]
    [(window.cursor.open
       bufnr (string.lower content)
       {:title +name+
        :similar ["nvlime_documentation"
                  "nvlime_description"]})
     bufnr]))

macroexpand
