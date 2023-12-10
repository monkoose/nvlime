(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))
(local ut (require "nvlime.utilities"))
(local psl-buf (require "parsley.buffer"))
(local psl-win (require "parsley.window"))

(local arglist {})
(local +bufname+ (buffer.gen-name buffer.names.arglist))
(local +filetype+ (buffer.gen-filetype buffer.names.arglist))

;;; {any} -> {any}
(fn calc-opts [args]
  (let [border-len 2
        wininfo (psl-win.get-info (vim.api.nvim_get_current_win))
        width (- wininfo.width wininfo.textoff border-len)
        height (math.min 4 (length args.lines))
        curline (vim.fn.line ".")
        row (if (> (- curline wininfo.topline)
                   (- (+ wininfo.topline wininfo.height) curline))
                (+ wininfo.winbar)
                (- wininfo.height height border-len))]
    {:relative "win"
     :row row
     :col wininfo.textoff
     :width width
     :height height
     :focusable false}))

;;; WinID ->
(fn win-callback [winid]
  (window.set-opt winid "conceallevel" 2)
  (vim.api.nvim_create_autocmd
    "InsertLeave"
    {:callback #(window.close-float winid)
     :once true}))

;;; string -> [WinID BufNr]
(fn arglist.show [content]
  "Opens/updates arglist window."
  (let [lines (ut.text->lines content)
        bufnr (buffer.create-nolisted +bufname+ +filetype+)
        opts (calc-opts {: lines})]
    (buffer.fill! bufnr lines)
    (case (psl-buf.visible? bufnr)
      (true winid) (do
                     (window.update-win-options winid opts)
                     [winid bufnr])
      _ [(window.open-float
           bufnr opts false false #(win-callback $1))
         bufnr])))

arglist
