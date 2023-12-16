(local km (require "nvlime.keymaps"))
(local buffer (require "nvlime.buffer"))
(local window (require "nvlime.window"))
(local ut (require "nvlime.utilities"))
(local pbuf (require "parsley.buffer"))
(local pwin (require "parsley.window"))
(local {: nvim_create_autocmd}
       vim.api)

(local keymaps {})

(local +bufname+ (buffer.gen-name buffer.names.keymaps))
(local +filetype+ (buffer.gen-filetype buffer.names.keymaps))

;;; string string string -> string
(fn format-keymap-line [mode map desc]
  (string.format "%-5s %-10s %s" mode map desc))

;;; integer integer integer -> bool
(fn cursor-overlap? [width col scr-col]
  (let [border-len 2]
    (if (and (>= scr-col col)
             (<= scr-col (+ col width border-len)))
      true)))

;;; {any} -> {any}
(fn calc-keymaps-opts [args]
  (let [[scr-height scr-width] (pwin.get-screen-size)
        [text-height text-width] (ut.calc-lines-size args.lines)
        width (math.min (- scr-width 4) text-width)
        center-col (window.center.calc-pos scr-width width 3)
        [scr-row scr-col] (pwin.get-screen-pos)
        title " nvlime buffer keymaps "
        ]
    (if (cursor-overlap? width center-col scr-col)
        (let [(bot? height) (window.find-horiz-pos
                              text-height scr-row scr-height)
              row (if bot? 1 (- (+ height 2)))
              col (- center-col scr-col)]
          {:relative "cursor"
           :row row
           :col col
           :width width
           :height height
           :title title
           :title_pos "center"
           :focusable false})
        (window.center.calc-opts
          {:lines args.lines
           :width 1
           :height 1
           :title title
           :title_pos "center"
           :nofocusable true}))))

;;; WinID ->
(fn win-callback [winid]
  (window.cursor.callback winid)
  (nvim_create_autocmd "WinLeave"
    {:callback #(window.close-float winid)
     :once true}))

;;; BufNr -> WinID
(fn open-keymaps-win [bufnr]
  (let [lines [(format-keymap-line "MODE" "MAP" "DESCRIPTION")]]
    (icollect [_ map (ipairs (km.buffer.get)) &into lines]
      (format-keymap-line map.mode map.lhs map.desc))
    ;; don't show the window when there is not keymaps
    (when (> (length lines) 1)
      (buffer.fill! bufnr lines)
      (window.open-float
        bufnr (calc-keymaps-opts {: lines})
        true false #(win-callback $1)))))

;;; -> [WinID BufNr]
(fn keymaps.toggle []
  (let [bufnr (buffer.create-scratch +bufname+ +filetype+)]
    (case (pbuf.visible? bufnr)
      (true winid) (do (window.close-float winid) [winid bufnr])
      _            [(open-keymaps-win bufnr) bufnr])))

keymaps
