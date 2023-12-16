(local buffer (require "nvlime.buffer"))
(local psl (require "parsley"))
(local pbuf (require "parsley.buffer"))
(local {: nvim_buf_set_extmark
        : nvim_create_namespace
        : nvim_buf_line_count}
       vim.api)

(local presentation
       {:coords {}
        :namespace (nvim_create_namespace
                      "nvlime_presentations")})

(var *repl-bufnr* nil)
(local *pending-coords* {})

;;; BufNr string ->
(fn set-presentation-begin [bufnr msg]
  (let [last-linenr (nvim_buf_line_count bufnr)
        id (psl.second msg)
        coords-list (or (. *pending-coords* id) [])]
    (table.insert coords-list {:begin [(+ last-linenr 1) 1]
                               :type "PRESENTATION"
                               :id id})
    (tset *pending-coords* id coords-list)))

;;; BufNr {any} ->
(fn set-presentation-end [bufnr coord]
  (let [last-linenr (nvim_buf_line_count bufnr)
        last-col (pbuf.line-length bufnr last-linenr)]
    (tset coord :end [last-linenr last-col])))

;;; [{any}] -> ({any} integer)
(fn get-pending-coord [coords-list]
  (var index 0)
  (var pending-coord nil)
  (each [i coord (ipairs coords-list)
         &until pending-coord]
    (when (not (. coord :end))
      (set index i)
      (set pending-coord coord)))
  (when pending-coord
    (values pending-coord index)))

(fn highlight-presentation [bufnr coord]
  (let [begin (. coord :begin)
        end (. coord :end)]
    (vim.defer_fn
      #(nvim_buf_set_extmark
         bufnr presentation.namespace
         (- (psl.first begin) 1) (- (psl.second begin) 1)
         {:end_row (- (psl.first end) 1)
          :end_col (psl.second end)
          :hl_group "nvlime_replCoord"})
      3)))

;;; Conn string ->
(fn presentation.on_start [conn msg]
  (let [(_ repl-bufnr) (pbuf.exists?
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
