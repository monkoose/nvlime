(import-macros {: return} "parsley.macros")
(local buffer (require "nvlime.buffer"))
(local psl (require "parsley"))
(local psl-buf (require "parsley.buffer"))

(local presentation
       {:coords {}
        :namespace (vim.api.nvim_create_namespace
                      "nvlime_presentations")})

(var *repl-bufnr* nil)
(var *pending-coords* {})

;;; BufNr string ->
(fn set-presentation-begin [bufnr msg]
  (let [last-linenr (vim.api.nvim_buf_line_count bufnr)
        id (psl.second msg)
        coords-list (or (. *pending-coords* id) [])]
    (table.insert coords-list {:begin [(+ last-linenr 1) 1]
                               :type "PRESENTATION"
                               :id id})
    (tset *pending-coords* id coords-list)))

;;; BufNr {any} ->
(fn set-presentation-end [bufnr coord]
  (let [last-linenr (vim.api.nvim_buf_line_count bufnr)
        last-col (psl-buf.line-length bufnr last-linenr)]
    (tset coord :end [last-linenr last-col])))

;;; [{any}] -> {any}
(fn get-pending-coord [coords-list]
  (each [i coord (ipairs coords-list)]
    (when (not (. coord :end))
      (return coord i))))

(fn highlight-presentation [bufnr coord]
  (let [begin (. coord :begin)
        end (. coord :end)]
    (vim.defer_fn
      #(vim.api.nvim_buf_set_extmark
         bufnr presentation.namespace
         (- (psl.first begin) 1) (- (psl.second begin) 1)
         {:end_row (- (psl.first end) 1)
          :end_col (psl.second end)
          :hl_group "nvlime_replCoord"})
      3)))

;;; Conn string ->
(fn presentation.on_start [conn msg]
  (let [(_ repl-bufnr) (psl-buf.exists?
                           (buffer.gen-repl-name
                             conn.cb_data.name))]
    (set *repl-bufnr* repl-bufnr)
    (when *repl-bufnr*
      (set-presentation-begin repl-bufnr msg))))

;;; Conn string ->
(fn presentation.on_end [_ msg]
  (when *repl-bufnr*
    (let [id (psl.second msg)
          coords-list (or (. *pending-coords* id) [])
          (pending-coord idx) (get-pending-coord coords-list)]
      (when pending-coord
        (set-presentation-end *repl-bufnr* pending-coord)
        (table.remove coords-list idx)
        (when (<= (length coords-list) 0)
          (tset *pending-coords* id nil))
        (let [startline (. pending-coord :begin 1)]
          (tset presentation.coords startline pending-coord))
        (highlight-presentation *repl-bufnr* pending-coord))))
  nil)

presentation
