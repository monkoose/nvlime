(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local describe {})

(local +name+ "description")
(local +bufname+ (buffer.gen-name +name+))
(local +filetype+ (buffer.gen-filetype +name+))

;;; string -> [WinID BufNr]
(fn describe.open [content]
  (let [bufnr (buffer.create-scratch
                 +bufname+ +filetype+)]
    [(window.cursor.open
       bufnr content
       {:title +name+
        :similar ["nvlime_documentation"
                  "nvlime_macroexpand"]})
     bufnr]))

describe
