(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local apropos {})

(local +name+ "apropos")
(local +bufname+ (buffer.gen-name +name+))
(local +filetype+ (buffer.gen-filetype +name+))

;;; {any} -> [string]
(fn content->lines [content]
  (var lines [])
  (each [_ item (ipairs content)]
    (when (= (?. item 1 :name) "DESIGNATOR")
      (let [end (match (?. item 3 :name)
                  nil ""
                  str (.. "  " (string.lower str)))]
        (table.insert lines (.. (. item 2) end)))))
  lines)

;;; WinID ->
(fn win-callback [winid]
  (window.set-opts winid {:cursorline true}))

;;; {any} -> [WinID BufNr]
(fn apropos.open [content]
  (let [lines (content->lines content)
        bufnr (buffer.create-scratch-with-conn-var!
                +bufname+ +filetype+)]
    [(window.center.open
       bufnr lines
       {:height 10 :width 60 :title +name+}
       #(win-callback $1))
     bufnr]))

apropos
