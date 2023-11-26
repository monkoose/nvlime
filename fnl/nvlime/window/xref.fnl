(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))
(local psl (require "parsley"))

(local xref {})

(local +filetype+ (buffer.gen-filetype buffer.names.xref))
(local +namespace+ (vim.api.nvim_create_namespace +filetype+))

(var *last-line* 1)
(var *prev-line* 0)

;;; [any] -> [string]
(fn content->lines [content]
  (var lines [])
  (each [_ xref (ipairs content)]
    (let [filename (?. xref 2 2 2)
          sym (string.gsub (. xref 1) "\n%s*" " ")]
      (table.insert lines sym)
      (table.insert lines (.. "  ;; " (or filename (?. xref 2 1 :name))))))
  lines)

;;; LineNr -> integer
(fn double-cursorline [linenr]
  (vim.api.nvim_buf_clear_namespace
    0 +namespace+ 0 -1)
  (vim.api.nvim_buf_set_extmark
    0 +namespace+ (- linenr 1) 0
    {:end_row (+ linenr 1)
     :end_col 0
     :hl_eol true
     :hl_group "CursorLine"}))

;;; WinID ->
(fn move-odds-only [winid]
  (let [[cur-line cur-col] (vim.api.nvim_win_get_cursor 0)]
    (when (psl.even? cur-line)
      (if (= cur-line *last-line*)
          (vim.api.nvim_win_set_cursor
            winid [(- cur-line 1) cur-col])
          (< *prev-line* cur-line)  ; elseif
          (vim.api.nvim_win_set_cursor
            winid [(+ cur-line 1) cur-col])
          (> *prev-line* cur-line)  ; elseif
          (vim.api.nvim_win_set_cursor
            winid [(- cur-line 1) cur-col])))
    (let [cur-line (vim.fn.line ".")]
      (set *prev-line* cur-line)
      (double-cursorline cur-line))))

;;; WinID BufNr ->
(fn win-callback [winid bufnr]
  (set *prev-line* 0)
  (set *last-line* (vim.api.nvim_buf_line_count bufnr))
  (vim.api.nvim_create_autocmd
    "CursorMoved" {:buffer bufnr
                   :callback #(move-odds-only winid)}))

;;; [any] {any} -> [WinID BufNr]
(fn xref.open [content config]
  (let [lines (content->lines content)
        bufnr (buffer.create-scratch-with-conn-var!
                (buffer.gen-name
                  config.conn-name buffer.names.xref)
                +filetype+)]
    [(window.center.open
       bufnr lines {:width 80
                    :height 10
                    :title buffer.names.xref}
       #(win-callback $1 $2))
     bufnr]))

xref
