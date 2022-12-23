(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))
(local ut (require "nvlime.utilities"))

(local disassembly {})

(local +bufname+ (buffer.gen-name buffer.names.disassembly))
(local +filetype+ (buffer.gen-filetype buffer.names.disassembly))

;;; string -> {..}
(fn content->lines [content]
  (let [lines (ut.text->lines content)]
    (var height 1)
    (var width 0)
    (each [idx line (ipairs lines)]
      (set height (+ height 1))
      (let [line-width (vim.fn.strdisplaywidth line)]
        (when (> line-width width)
          (set width line-width))
        (tset lines idx (string.gsub line "^%s*;" "" 1))))
    (table.insert lines 3
                  (string.rep vim.g.nvlime_horiz_sep width))
    {: lines : height : width}))

;;; string {..} -> [WinID BufNr]
(fn disassembly.open [content]
  "Opens disassembly window."
  (let [text (content->lines content)
        bufnr (buffer.create-scratch
                +bufname+ +filetype+)
        config {:height text.height
                :width text.width
                :title buffer.names.disassembly}]
    [(window.center.open bufnr text.lines config)
     bufnr]))

disassembly
