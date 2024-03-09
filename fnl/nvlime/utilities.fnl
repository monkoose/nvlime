(local psl (require "parsley"))
(local {: nvim_win_set_cursor
        : nvim_win_get_cursor}
       vim.api)

(fn text->lines [text]
  (if text
      (if (psl.string? text)
          (vim.split text "\n" {:trimempty true})
          text)
      []))

(fn calc-lines-size [lines]
  (var width 0)
  (var height 0)
  (each [_ line (ipairs lines)]
    (let [line-width (vim.fn.strdisplaywidth line)]
      (set height (+ height 1))
      (when (> line-width width)
        (set width line-width))))
  [height width])

;;; [any] -> {any}
(fn plist->table [plist]
  (let [t {}]
    (for [i 1 (length plist) 2]
      (tset t (. plist i :name) (. plist (+ i 1))))
    t))

;;; string ->
(fn echo [str level]
  (vim.notify (.. "nvlime: " str)
              (or level vim.log.levels.INFO)))

(fn echo-warning [str]
  (echo str vim.log.levels.WARN))

(fn echo-error [str]
  (echo str vim.log.levels.ERROR))

;;; {any} -> LineNr Col LineNr Col
(fn coord-range [coord]
  (let [[begin-l begin-c] (. coord :begin)
        [end-l end-c] (. coord :end)]
    (values begin-l begin-c end-l end-c)))

;;; {any} LineNr Col -> bool
(fn in-coord-range? [coord linenr col]
  (let [(begin-l begin-c end-l end-c)
        (coord-range coord)]
    (if (>= end-l linenr begin-l)
        (if (= linenr begin-l end-l) (>= end-c col begin-c)
            (= linenr begin-l) (>= col begin-c)
            (= linenr end-l) (<= col end-c)
            true)
        false)))

;;; WinID -> [LineNr Col]
(fn get-win-cursor [winid]
  "Returns tuple of cursor line and column numbers.
  Unlike `nvim_win_get_cursor` they are 1-indexed."
  (let [[linenr col-0] (nvim_win_get_cursor winid)]
    [linenr (+ col-0 1)]))

;;; WinID [LineNr Col] ->
(fn set-win-cursor [winid pos]
  "Sets the window cursor at the `pos` (tuple with linenr and column).
  Unlike `nvim_win_set_cursor` linenr and column are 1-indexed."
  (let [linenr (psl.first pos)
        col-0 (- (psl.second pos) 1)]
    (nvim_win_set_cursor
      winid [linenr col-0])))

;;; fn [any] -> any|nil
(fn find-if [pred list]
  (var result nil)
  (each [_ item (ipairs list) &until result]
    (when (pred item)
      (set result item)))
  result)

{: text->lines
 : echo
 : echo-warning
 : echo-error
 : plist->table
 : calc-lines-size
 : get-win-cursor
 : set-win-cursor
 : in-coord-range?
 : find-if}
