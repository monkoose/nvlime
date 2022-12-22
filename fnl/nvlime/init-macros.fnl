(fn return [...]
  (let [return-values#
        (accumulate [str "" _ s (ipairs [...])]
          (do
            (assert-compile (or (= (type s) "boolean")
                                (sym? s)))
            (.. str " " (tostring s) ",")))]
    `(lua ,(.. "return" (return-values#:gsub ",$" "")))))

{: return}
