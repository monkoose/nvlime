(local pbuf (require "parsley.buffer"))
(local {: nvim_create_autocmd
        : nvim_buf_call
        : nvim_buf_get_option
        : nvim_buf_set_name
        : nvim_buf_set_var
        : nvim_buf_set_option
        : nvim_clear_autocmds
        : nvim_create_buf
        : nvim_buf_set_lines
        : nvim_buf_get_var
        : nvim_exec}
       vim.api)

(local buffer {})

(tset buffer
      :names {:repl "repl"
              :sldb "sldb"
              :xref "xref"
              :input "input"
              :notes "notes"
              :trace "trace"
              :server "server"
              :apropos "apropos"
              :arglist "arglist"
              :keymaps "keymaps"
              :threads "threads"
              :inspector "inspector"
              :description "description"
              :disassembly "disassembly"
              :macroexpand "macroexpand"
              :documentation "documentation"})

(macro with-modifiable [bufnr ...]
  "Allows making changes to the text in the buffer
even if it's option `nomodifiable` is set."
  `(let [old-mod# (nvim_buf_get_option ,bufnr :modifiable)]
     (nvim_buf_set_option ,bufnr :modifiable true)
     (do ,(unpack [...]))
     (nvim_buf_set_option ,bufnr :modifiable old-mod#)
     nil))

;;; ...string -> BufName
(fn buffer.gen-name [...]
  "Generate name for the nvlime buffers."
  (.. "nvlime://" (table.concat [...] "/")))

;;; string -> BufName
(fn buffer.gen-repl-name [conn-name]
  "Generates repl buffer name."
  (buffer.gen-name conn-name buffer.names.repl))

;;; string integer -> BufName
(fn buffer.gen-sldb-name [conn-name thread]
  "Generates sldb buffer name."
  (buffer.gen-name
    conn-name buffer.names.sldb thread))

;;; string -> string
(fn buffer.gen-filetype [suffix]
  "Generates nvlime filetype."
  (.. "nvlime_" suffix))

;;; BufNr string -> any
(fn buffer.get-opt [bufnr opt]
  "Gets buffer local option `opt`."
  (nvim_buf_get_option bufnr opt))

;;; BufNr {any} ->
(fn buffer.set-opts [bufnr opts]
  "Sets buffer local options from the hash table where
key - option name, value - option value."
  (each [opt val (pairs opts)]
    (nvim_buf_set_option bufnr opt val)))

;;; BufNr {any} ->
(fn buffer.set-vars [bufnr vars]
  "Sets buffer variables from the hash table where
key - var name, value - var value."
  (each [v val (pairs vars)]
    (nvim_buf_set_var bufnr v val)))

;;; TODO convert to macro
;;; BufNr [string] ->
(fn buffer.vim-call! [bufnr cmds]
  "Calls vim commands temporally setting buffer with `bufnr` as current buffer."
  (nvim_buf_call
    bufnr #(each [_ c (ipairs cmds)]
             (nvim_exec c false))))

;;; BufNr ->
(fn buffer.set-conn-var! [bufnr]
  "Sets b:nvlime_conn variable to current connection with
proper vimscript methods (calling it with vimscript)."
  (buffer.vim-call! bufnr ["call nvlime#connection#Get()"]))

;;; BufNr -> ?{any}
(fn buffer.get-conn-var! [bufnr]
  "Returns b:nvlime_conn variable, but without vimscript methods
in it. Returns nil if it is not present."
  (buffer.set-conn-var! bufnr)
  (case (pcall nvim_buf_get_var bufnr "nvlime_conn")
    (true conn) conn))

;;; BufName bool ?(fn [BufNr]) -> BufNr
(fn buffer.create [name listed? callback]
  "Creates a new buffer with the default options and returns its number.
Additional configuration can be done with `callback` function."
  (let [bufnr (nvim_create_buf listed? false)]
    (nvim_buf_set_name bufnr name)
    (buffer.set-opts bufnr {:modifiable false
                            :swapfile false
                            :modeline false
                            :buftype "nofile"})
    ;;; Always preserve 'nolisted' option, because some neovim
    ;;; keybinding can change it's value (like `C-^`)
    (when (not listed?)
      (nvim_create_autocmd "BufWinEnter"
        {:buffer bufnr
        :callback #(buffer.set-opts bufnr {:buflisted false})})
      ;; clear autocmds
      (nvim_create_autocmd "BufWipeout"
        {:buffer bufnr
        :callback #(nvim_clear_autocmds
                     {:event "BufWinEnter"
                     :buffer bufnr})
        :once true}))
    (when callback (callback bufnr))
    bufnr))

;;; BufName bool ?(fn [BufNr]) -> BufNr
(fn buffer.create-if-not-exists [name listed? callback]
  "Creates new buffer only if buffer with the `name` doesn't exists.
Returns buffer number in any case."
  (if (pbuf.exists? name)
      (vim.fn.bufnr name)
      (buffer.create name listed? callback)))

;;; BufName FileType -> BufNr
(fn buffer.create-listed [name filetype]
  "Creates a new buffer which would be listed."
  (buffer.create-if-not-exists
    name true #(buffer.set-opts $ {: filetype})))

;;; BufName FileType -> BufNr
(fn buffer.create-nolisted [name filetype]
  "Creates new buffer which wouldn't be listed.
Not shown up for `:ls`, but present for `:ls!`"
  (buffer.create-if-not-exists
    name false #(buffer.set-opts $ {: filetype})))

;;; BufName FileType -> BufNr
(fn buffer.create-scratch [name filetype]
  "Creates new buffer which wouldn't be listed.
And also would be wiped out after becomeing hidden."
  (buffer.create-if-not-exists
    name false #(buffer.set-opts $ {:filetype filetype
                                    :bufhidden "wipe"})))

;;; BufName FileType -> BufNr
(fn buffer.create-scratch-with-conn-var! [name filetype]
  "Creates new scratch buffer and also set `b:nvlime_conn`."
  (let [callback
        (fn [bufnr]
          (buffer.set-conn-var! bufnr)
          (buffer.set-opts bufnr {:filetype filetype
                                  :bufhidden "wipe"}))]
    (buffer.create-if-not-exists name false #(callback $))))

;;; BufNr [string] ...[string] ->
(fn buffer.fill! [bufnr lines ...]
  "Changes all lines of the buffer with `bufnr` to `lines` and
any other variable number of [string] appended right after the `lines`."
  (with-modifiable bufnr
    (nvim_buf_set_lines bufnr 0 -1 false lines)
    (when ...
      (each [_ ls (ipairs [...])]
        (nvim_buf_set_lines bufnr -1 -1 false ls)))))

;;; BufNr ...[string] ->
(fn buffer.append! [bufnr ...]
  "Appends `...` any number of list of strings to the end of the
  buffer with `bufnr`."
  (with-modifiable bufnr
    (when ...
      (each [_ ls (ipairs [...])]
        (nvim_buf_set_lines bufnr -1 -1 false ls)))))

buffer
