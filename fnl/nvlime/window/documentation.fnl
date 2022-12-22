(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local documentation {})
(local +name+ "documentation")
(local +bufname+ (buffer.gen-name +name+))
(local +filetype+ (buffer.gen-filetype +name+))

;;; string -> [WinID BufNr]
(fn documentation.open [content]
  (let [bufnr (buffer.create-scratch
                +bufname+ +filetype+)]
    [(window.cursor.open
       bufnr content {:title +name+
                      :similar ["nvlime_description"
                                "nvlime_macroexpand"]})
     bufnr]))

documentation
