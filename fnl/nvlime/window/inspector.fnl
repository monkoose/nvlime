(local buffer (require "nvlime.buffer"))
(local window (require "nvlime.window"))
(local ut (require "nvlime.utilities"))
(local psl (require "parsley"))
(local psl-list (require "parsley.list"))

(local inspector {})

(local +bufname+ (buffer.gen-name buffer.names.inspector))
(local +filetype+ (buffer.gen-filetype buffer.names.inspector))
(local +namespace+ (vim.api.nvim_create_namespace +filetype+))

(var *content-title* "")
(var *coords* [])
(var *content-start* 0)
(var *content-end* 0)
;;; string integer -> [any]
(macro range-button [name id]
  [{:name "RANGE" :package "KEYWORD"} name id])

;;; [any] -> [any]
(fn make-range-buttons [content]
  (let [buttons []
        add-separator #(table.insert buttons "  ")
        add-newline #(table.insert buttons "\n")
        add-button (fn [name id]
                     (table.insert
                       buttons (range-button name id)))]
    (set *content-start* (. content 3))
    (set *content-end* (. content 4))
    (when (> *content-start* 0)
      (add-newline)
      (add-button "[prev range]" -1))
    (when (> (. content 2) *content-end*)
      (if (psl.empty? buttons)
          (add-newline)
          (add-separator))
      (add-button "[next range]" 1))
    (when (not (psl.empty? buttons))
      (add-separator)
      (add-button "[all content]" 0)
      (table.insert buttons "\n"))
    buttons))

;;; [any] -> [string]
(fn content->lines* [content]
  (var lines [])
  (var line "")
  (local get-cur-pos #[(+ (length lines) 1) (+ (length line) 1)])
  (fn add-lines [c]
    (if (psl.string? c)
        (if (= c "\n")
            (let [splitted-line (vim.split line "\n")]
              (icollect [_ l (ipairs splitted-line) &into lines] l)
              (set line ""))
            (set line (.. line c)))
        (psl.list? c)
        (if (and (= (length c) 3)
                 (psl.hash-table? (. c 1)))
            (let [start (get-cur-pos)]
              (add-lines (. c 2))
              (table.insert *coords* {:id (. c 3)
                                      :type (. c 1 "name")
                                      :begin start
                                      :end (get-cur-pos)}))
            (each [_ i (ipairs c)]
              (add-lines i)))))
  (add-lines content)
  lines)

;;; BufNr ->
(fn add-coords-highlight [bufnr]
  (vim.api.nvim_buf_clear_namespace
    bufnr +namespace+ 0 1)
  (let [set-extmark (fn [begin end hl]
                      (vim.api.nvim_buf_set_extmark
                        bufnr +namespace+
                        (- (. begin 1) 1)
                        (- (. begin 2) 1)
                        {:end_row (- (. end 1) 1)
                         :end_col (- (. end 2) 1)
                         :hl_group hl}))]
    (each [_ coord (ipairs *coords*)]
      (match coord.type
        "ACTION" (set-extmark
                   coord.begin coord.end
                   "nvlime_inspectorAction")
        "VALUE"  (set-extmark
                   coord.begin coord.end
                   "nvlime_inspectorValue")
        "RANGE"  (set-extmark
                   coord.begin coord.end
                   "nvlime_inspectorAction")))))

;;; [..] -> [string]
(fn content->lines [content]
  (let [content* (ut.plist->table content)
        lookup-content (fn [key]
                         (or (. content* key)
                             (. content* (string.lower key))))
        content-data (lookup-content "CONTENT")
        title (lookup-content "TITLE")
        range-buttons (make-range-buttons content-data)
        lines (content->lines*
                (psl-list.concat
                  [title "\n" "\n"]
                  (. content-data 1)
                  range-buttons))]
    (set *content-title* title)
    lines))

;;; BufNr ->
(fn buf-callback [bufnr]
  (buffer.set-opts
    bufnr {:bufhidden "wipe"
           :filetype +filetype+})
  (buffer.set-conn-var! bufnr))

;;; {any} -> [WinID BufNr]
(fn inspector.open [content]
  "Opens inspector window."
  (set *coords* [])
  (let [lines (content->lines content)
        bufnr (buffer.create-if-not-exists
                +bufname+
                false
                #(buf-callback $))]
    (let [winid (window.center.open
                  bufnr lines
                  {:height 12
                   :width 80
                   :title buffer.names.inspector})]
      (add-coords-highlight bufnr)
      (buffer.set-vars
        bufnr {:nvlime_inspector_title *content-title*
               :nvlime_inspector_coords *coords*
               :nvlime_inspector_content_start *content-start*
               :nvlime_inspector_content_end *content-end*})
      [winid bufnr])))

inspector
