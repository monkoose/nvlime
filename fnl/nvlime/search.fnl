(import-macros {: return} "parsley.macros")
(local {: nvim_win_get_cursor
        : nvim_win_set_cursor
        : nvim_buf_get_lines
        : nvim_buf_line_count}
       vim.api)

(local skip-groups
       ["string"
        "character"
        "comment"
        "singlequote"
        "escape"
        "symbol"])

(local search {})

; (macro with-cursor [...]
;   `(let [cur-pos# (nvim_win_get_cursor 0)
;          result# ,(unpack [...])]
;      (nvim_win_set_cursor 0 cur-pos#)
;      result#))

(fn syntax-on? []
  (not= vim.b.current_syntax nil))

(fn get-synname [synid]
  (string.lower (vim.fn.synIDattr synid "name")))

(fn syn-ids [line col]
  (let [synstack (vim.fn.synstack line col)
        len (length synstack)]
    [(. synstack len)
     (. synstack (- len 1))
     (. synstack (- len 2))]))

(fn contains-any [str strings]
  (var result false)
  (each [_ pattern (ipairs strings) &until result]
    (when (not= (string.find str pattern 1 true)
                nil)
      (set result true)))
  result)

;; LineNr ColNr -> boolean
(fn skip-region? [line col]
  (var result false)
  (each [_ synid (ipairs (syn-ids line col)) &until result]
    (when (contains-any (get-synname synid) skip-groups)
      (set result true)))
  result)

(fn skip-by-region [line col]
  (if (skip-region? line col)
      true
      false))

(fn skip-same-paren [backward?]
  (var count 0)
  (let [same-paren (if backward? ")" "(")
        inc-skip (fn []
                   (set count (+ count 1))
                   true)
        dec-skip (fn []
                   (set count (- count 1))
                   true)]
    (fn [paren]
      (if (= paren same-paren)
          (inc-skip)
          (if (= count 0)
              false
              (dec-skip))))))

(fn find-forward [text pattern init]
  (let [(index _ bracket) (string.find text
                                       pattern
                                       (and init (+ 1 init)))]
    (values index bracket)))

(fn find-backward [reversed-text pattern init]
  (let [len (+ 1 (length reversed-text))
        (index bracket) (find-forward reversed-text
                                      pattern
                                      (and init (- len init)))]
    (when index
      (values (- len index) bracket))))

(fn get-lines [start end]
  (let [first (- start 1)]
    (nvim_buf_get_lines
      0 first end false)))

(fn forward-matches [pattern line col end same-column?]
  (let [lines (get-lines line end)]
    (var i 1)
    (var text (. lines i))
    (var index (if same-column?
                   (- col 1)
                   col))
    (var capture nil)
    #(while text
       (set (index capture) (find-forward text pattern index))
       (if index
           (let [line_ (+ (- i 1) line)]
             (return line_ index capture))
           (do
             (set i (+ 1 i))
             (set text (. lines i)))))))

(fn backward-matches [pattern line col start same-column?]
  (let [lines (get-lines start line)
        len (length lines)
        offset (- line len)
        reverse (fn [list i]
                  (let [str (. list i)]
                    (when str
                      (str:reverse))))]
    (var i len)
    (var index (if same-column? (+ 1 col) col))
    (var capture nil)
    (var reversed-text (reverse lines i))
    #(while reversed-text
       (set (index capture) (find-backward reversed-text pattern index))
       (if index
           (let [line_ (+ offset i)]
             (return line_ index capture))
           (do
             (set i (- i 1))
             (set reversed-text (reverse lines i)))))))

;;; boolean -> integer
(fn search.top_form_line [backward?]
  (let [re "^\\s*\\%($\\|;.*\\)\\n("
        find-top (fn [flags]
                   (vim.fn.search re flags))]
    (if backward?
        (vim.fn.search re "bnW")
        (let [stopline (vim.fn.search re "nW")]
          (if (= stopline 0)
              (nvim_buf_line_count 0)
              stopline)))))

(fn search.pair_paren [line col opts]
  (let [o (or opts {})
        pattern "([)(])"
        stopline (or o.stopline (search.top_form_line o.backward))
        skip-paren (skip-same-paren o.backward)
        matches (if o.backward
                    backward-matches
                    forward-matches)
        skip (fn [l c paren]
               (if (skip-by-region l c)
                   true
                   (skip-paren paren)))]
    (var result nil)
    (each [l c cap (matches pattern line col stopline o.same-column?)
           &until result]
      (when (not (skip l c cap))
        (set result [l c])))
    (if result
        result
        [0 0])))

search
