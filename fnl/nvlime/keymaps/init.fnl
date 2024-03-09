(local opts (require "nvlime.config"))
(local psl (require "parsley"))
(local ut (require "nvlime.utilities"))
(local {: nvim_replace_termcodes
        : nvim_feedkeys
        : nvim_buf_set_keymap
        : nvim_buf_get_keymap
        : nvim_eval}
       vim.api)

(local keymaps
       {:leader opts.leader
        :buffer {}})

(fn with-leader [key]
  (.. opts.leader key))

(local global-mappings
       {:normal {:close_current_window "q"
                 :keymaps_help ["<F1>" (with-leader "?")]
                 :close_nvlime_windows (with-leader "ww")
                 :close_floating_window "<Esc>"
                 :scroll_up "<C-p>"
                 :scroll_down "<C-n>"
                 :split_left "<C-w>h"
                 :split_right "<C-w>l"
                 :split_above "<C-w>k"
                 :split_below "<C-w>j"}})

(local lisp-mappings
       {:normal {:interaction_mode (with-leader "<CR>")
                 :load_file (with-leader "l")
                 :disassemble {:expr (with-leader "aa")
                               :symbol (with-leader "as")}
                 :set_package (with-leader "p")
                 :set_breakpoint (with-leader "b")
                 :show_threads (with-leader "T")
                 :connection {:new (with-leader "cc")
                              :switch (with-leader "cs")
                              :rename (with-leader "cR")
                              :close (with-leader "cd")}
                 :server {:new (with-leader "rr")
                          :show (with-leader "rv")
                          :show_selected (with-leader "rV")
                          :stop (with-leader "rs")
                          :stop_selected (with-leader "rS")
                          :rename (with-leader "rR")
                          :restart (with-leader "rt")}
                 :repl {:show (with-leader "so")
                        :clear (with-leader "sC")
                        :send_atom_expr (with-leader "ss")
                        :send_atom (with-leader "sa")
                        :send_expr (with-leader "se")
                        :send_toplevel_expr (with-leader "st")
                        :prompt (with-leader "si")
                        :send_buffer (with-leader "sb")}
                 :macro {:expand (with-leader "mm")
                         :expand_once (with-leader "mo")
                         :expand_all (with-leader "ma")}
                 :compile {:expr (with-leader "ce")
                           :toplevel_expr (with-leader "ct")
                           :file (with-leader "cf")}
                 :xref {:function {:callers (with-leader "xc")
                                   :callees (with-leader "xC")}
                        :symbol {:references (with-leader "xr")
                                 :bindings (with-leader "xb")
                                 :definition (with-leader "xd")
                                 :set_locations (with-leader "xs")}
                        :macro {:callers (with-leader "xe")}
                        :class {:methods (with-leader "xm")}
                        :prompt (with-leader "xi")}
                 :describe {:operator (with-leader "do")
                            :atom (with-leader "da")
                            :prompt (with-leader "di")}
                 :apropos {:prompt (with-leader "ds")}
                 :arglist {:show (with-leader "dr")}
                 :documentation {:operator (with-leader "ddo")
                                 :atom ["K" (with-leader "dda")]
                                 :prompt (with-leader "ddi")}
                 :inspect {:atom_expr (with-leader "ii")
                           :atom (with-leader "ia")
                           :expr (with-leader "ie")
                           :toplevel_expr (with-leader "it")
                           :symbol (with-leader "is")
                           :prompt (with-leader "in")}
                 :trace {:show (with-leader "td")
                         :toggle (with-leader "tt")
                         :prompt (with-leader "ti")}
                 :undefine {:function (with-leader "uf")
                            :symbol (with-leader "us")
                            :prompt (with-leader "ui")}}
        :insert {:space_arglist "<Space>"
                 :cr_arglist "<CR>"}
        :visual {:repl {:send_selection (with-leader "s")}
                 :compile {:selection (with-leader "c")}
                 :inspect {:selection (with-leader "i")}}})

(local input-mappings
       {:normal {:complete "<CR>"}
        :insert {:keymaps_help "<F1>"
                 :complete "<CR>"
                 :next_history "<C-n>"
                 :prev_history "<C-p>"
                 :leave_insert "<Esc>"}})

(local repl-mappings
       {:normal {:interrupt "<C-c>"
                 :clear "C"
                 :inspect_result "i"
                 :yank_result "y"
                 :next_result ["<Tab>" "<C-n>"]
                 :prev_result ["<S-Tab>" "<C-p>"]}})

(local sldb-mappings
       {:normal {:action "<CR>"
                 :details "d"
                 :frame {:toggle_details "d"
                         :source "S"
                         :source_split "<C-s>"
                         :source_vsplit "<C-v>"
                         :source_tab "<C-t>"
                         :restart "r"
                         :eval_expr "e"
                         :send_expr "E"
                         :disassemble "D"
                         :return_result "R"
                         :step "s"}
                 :local_var {:source "O"
                             :inspect "i"}
                 :step_over "x"
                 :step_out "o"
                 :abort "a"
                 :continue "c"
                 :inspect_condition "C"}})

(local apropos-mappings
       {:normal {:inspect "i"}})

(local inspector-mappings
       {:normal {:action "<CR>"
                 :current {:send "s"
                           :source "o"}
                 :inspected {:send "S"
                             :source "O"
                             :previous "<C-o>"
                             :next "<C-i>"}
                 :next_field "<C-n>"
                 :prev_field ["<S-Tab>" "<C-p>"]
                 :refresh "R"}})

(local notes-mappings
       {:normal {:source "<CR>"
                 :source_split "<C-s>"
                 :source_vsplit "<C-v>"
                 :source_tab "<C-t>"}})

(local server-mappings
       {:normal {:connect (with-leader "c")
                 :stop (with-leader "s")}})

(local threads-mappings
       {:normal {:interrupt "<C-c>"
                 :kill "K"
                 :invoke_debugger "D"
                 :refresh "r"}})

(local trace-mappings
       {:normal {:action "<CR>"
                 :refresh "R"
                 :inspect_value "i"
                 :send_value "s"
                 :next_field ["<Tab>" "<C-n>"]
                 :prev_field ["<S-Tab>" "<C-p>"]}})

(local xref-mappings
       {:normal {:source "<CR>"
                 :source_split "<C-s>"
                 :source_vsplit "<C-v>"
                 :source_tab "<C-t>"}})

(local mrepl-mappings
       {:normal {:clear (with-leader "C")
                 :disconnect (with-leader "D")}
        :insert {:space_arglist "<Space>"
                 :cr_arglist "<C-j>"
                 :submit "<CR>"
                 :interrupt "<C-c>"}})

(local default-mappings
       {:global global-mappings
        :lisp lisp-mappings
        :input input-mappings
        :repl repl-mappings
        :sldb sldb-mappings
        :apropos apropos-mappings
        :inspector inspector-mappings
        :notes notes-mappings
        :server server-mappings
        :threads threads-mappings
        :trace trace-mappings
        :xref xref-mappings
        :mrepl mrepl-mappings})

(tset keymaps :mappings (vim.tbl_deep_extend
                          "force"
                          default-mappings
                          (or vim.g.nvlime_mappings {})))

(fn from-keycode [key]
  (nvim_replace_termcodes key true false true))

(fn keymaps.feedkeys [keys]
  (nvim_feedkeys (from-keycode keys) "n" false))

;;; Executes a mapping from a dict returned by maparg()
;;; Cases:
;;; 1. map-expression -- compute rhs and feed keys
;;;    N.B.: if there is a callback, then use it to compute rhs
;;;          (idea due to anuvyklack/keymap-amend.nvim)
;;; 2. just a calback -- just call it
;;; 3. regular mapping -- feed keys from rhs directly
(fn exec-map [map]
  (let [keys (if map.callback
               (map.callback)
               (if (= 1 map.expr) 
                 (nvim_eval map.rhs) 
                 map.rhs))]
    (when (or (= 1 map.expr) (not map.callback))
      (nvim_feedkeys (from-keycode keys) (if (= 1 map.noremap) "n" "m") false))))

;;; string string -> fn
;;; Returns a function which executes the specified mapping
(fn get-buf-map-as-fn [mode lhs]
  (let [map (vim.fn.maparg lhs mode nil true)]
    (if (and map (not (vim.tbl_isempty map)))
      #(exec-map map)
      #(nvim_feedkeys (from-keycode lhs) mode false))))

;;; string string fn|string string ->
(fn set-buf-map [mode lhs rhs desc]
  (let [opts {:noremap true
              :nowait true
              :silent true
              :desc desc}]
    (if (= (type rhs) "function")
      (do
        (tset opts :callback (let [f (get-buf-map-as-fn mode lhs)]
                               #(rhs f)))
        (nvim_buf_set_keymap 0 mode lhs "" opts))
      (nvim_buf_set_keymap 0 mode lhs rhs opts))))

;;; string string|list fn|string string ->
(fn set-buf-map* [mode lhs rhs desc]
  (if (psl.string? lhs)
      (when (not= lhs "")
        (set-buf-map mode lhs rhs desc))
      (each [_ l (ipairs lhs)]
        (set-buf-map mode l rhs desc))))

(fn keymaps.buffer.normal [lhs rhs desc]
  (set-buf-map* "n" lhs rhs desc))

(fn keymaps.buffer.insert [lhs rhs desc]
  (set-buf-map* "i" lhs rhs desc))

(fn keymaps.buffer.visual [lhs rhs desc]
  (set-buf-map* "v" lhs rhs desc))

(fn keymaps.buffer.get []
  (let [maps []]
    (each [_ mode (ipairs ["n" "i" "v"])]
      (icollect [_ map (ipairs (nvim_buf_get_keymap 0 mode))
                 &into maps]
        (when (and map.desc (string.find map.desc "^nvlime:"))
          {:mode map.mode
           :lhs (string.gsub map.lhs " " "<SPACE>")
           :desc (string.gsub map.desc "^nvlime: " "")})))
    maps))

keymaps
