(local psl (require "parsley"))

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

{: text->lines
 : plist->table
 : calc-lines-size}
