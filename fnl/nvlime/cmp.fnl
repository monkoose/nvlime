(import-macros {: return} "parsley.macros")
(local lsp-types (require "cmp.types.lsp"))
(local buffer (require "nvlime.buffer"))
(local opts (require "nvlime.config"))
(local psl (require "parsley"))
(require "cmp.types.cmp")

(local +fuzzy?+ (not (psl.empty?
                       (psl.filter
                         #(= "SWANK-FUZZY" $)
                         opts.contribs))))

(local flag-kind
       {:b lsp-types.CompletionItemKind.Variable
        :f lsp-types.CompletionItemKind.Function
        :g lsp-types.CompletionItemKind.Method
        :c lsp-types.CompletionItemKind.Class
        :t lsp-types.CompletionItemKind.Class
        :m lsp-types.CompletionItemKind.Operator
        :s lsp-types.CompletionItemKind.Operator
        :p lsp-types.CompletionItemKind.Module})

(local kind-precedence
       [lsp-types.CompletionItemKind.Module
        lsp-types.CompletionItemKind.Class
        lsp-types.CompletionItemKind.Operator
        lsp-types.CompletionItemKind.Method
        lsp-types.CompletionItemKind.Function
        lsp-types.CompletionItemKind.Variable])

;;; string -> ?number
(fn flags->kind [flags]
  (var kinds {})
  (for [i 1 (length flags)]
    (let [kind (. flag-kind (flags:sub i i))]
      (when kind
        (tset kinds kind true))))
  (each [_ kind (ipairs kind-precedence)]
    (when (. kinds kind)
      (return kind))))

;;; {any} ->
(fn set-documentation [item]
  (let [get-documentation (. vim.fn "nvlime#cmp#get_docs")]
    (get-documentation
      item.label
      #(tset item :documentation
             (string.gsub $ "^Documentation for the symbol.-\n\n" "" 1)))))

(local get-lsp-kind
       (if +fuzzy?+
           (fn [item]
             (let [flags (. item 4)]
               {:label (psl.first item)
               :labelDetails {:detail flags}
               :kind (or (flags->kind flags)
                         lsp-types.CompletionItemKind.Keyword)}))
           #{:label $}))

(local get-completion
       (. vim.fn (if +fuzzy?+
                     "nvlime#cmp#get_fuzzy"
                     "nvlime#cmp#get_simple")))

(var source {})

(fn source.is_available [self]
  (not (psl.null? (buffer.get-conn-var! 0))))

(fn source.get_debug_name [self]
  "CMP Nvlime")

(fn source.get_keyword_pattern [self]
  "\\k\\+")

(fn source.complete [self params callback]
  (let [on-done (fn [candidates]
                  (callback
                    (icollect [_ c (ipairs (or candidates []))]
                      (get-lsp-kind c))))
        input (string.sub params.context.cursor_before_line
                          params.offset)]
    (get-completion input on-done)))

(fn source.resolve [self item callback]
  (set-documentation item)
  ;; defer_fn required for documentation to show up
  (vim.defer_fn #(callback item) 5))

source
