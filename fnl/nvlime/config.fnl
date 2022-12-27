(local config {})

(local default-indent-keywords
       {:defun 2
        :defmacro 2
        :defgeneric 2
        :defmethod 2
        :deftype 2
        :lambda 1
        :if 3
        :unless 1
        :when 1
        :case 1
        :ecase 1
        :typecase 1
        :etypecase 1
        :eval-when 1
        :let 1
        :let* 1
        :flet 1
        :labels 1
        :macrolet 1
        :symbol-macrolet 1
        :do 2
        :do* 2
        :do-all-symbols 1
        :do-external-symbols 1
        :do-symbols 1
        :dolist 1
        :dotimes 1
        :destructuring-bind 2
        :multiple-value-bind 2
        :prog1 1
        :progv 2
        :with-input-from-string 1
        :with-output-to-string 1
        :with-open-file 1
        :with-open-stream 1
        :with-package-iterator 1
        :unwind-protect 1
        :handler-bind 1
        :handler-case 1
        :restart-bind 1
        :restart-case 1
        :with-simple-restart 1
        :with-slots 2
        :with-accessors 2
        :print-unreadable-object 1
        :block 1})

(local default-contribs
       ["SWANK-ARGLISTS"
        "SWANK-ASDF"
        "SWANK-C-P-C"
        "SWANK-FANCY-INSPECTOR"
        "SWANK-FUZZY"
        "SWANK-PACKAGE-FU"
        "SWANK-PRESENTATIONS"
        "SWANK-REPL"])

(local default-leader
       (or (?. vim.g :nvlime_config :leader) "<LocalLeader>"))

(fn with-leader [key]
  (.. default-leader key))

(local
  default-opts
  {:leader default-leader
   :implementation "sbcl"
   :address {:host "127.0.0.1"
             :port 7002}
   :connect_timeout -1
   :compiler_policy {}
   :indent_keywords default-indent-keywords
   :input_history_limit 100
   :contribs default-contribs
   :user_contrib_initializers {}
   :autodoc {:enable false
             :max_level 5
             :max_lines 50}
   :main_window {:position "right"}
   :floating_window {:border "single"
                     :scroll_step 3
                     :scroll {:up "<C-p>"
                              :down "<C-n"}}
   :cmp {:enable false}
   :arglist {:enable true}})

(tset config :options (vim.tbl_deep_extend
                        "force"
                        default-opts
                        (or vim.g.nvlime_config {})))

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

(local input-mappings
       {:normal {:complete "<CR>"}
        :insert {:keymaps_help "<F1>"
                 :complete "<CR>"
                 :prev_history "<C-n>"
                 :next_history "<C-p>"
                 :leave_insert "<Esc>"}})

(local repl-mappings
       {:normal {:interrupt "<C-c>"
                 :clear "C"
                 :inspect_result "i"
                 :yank_result "y"
                 :next_result ["<Tab>" "<C-n>"]
                 :prev_result ["<S-Tab>" "<C-p>"]}})

(local lisp-mappings
       {:normal {:interaction_mode (with-leader "<CR>")
                 :load_file (with-leader "l")
                 :disassemble (with-leader "a")
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
                        :prompt (with-leader "si")}
                 :xref {:function {:callers (with-leader "xc")
                                   :callees (with-leader "xC")}
                        :symbol {:references (with-leader "xr")
                                 :bindings (with-leader "xb")
                                 :definition (with-leader "xd")
                                 :set_locations (with-leader "xs")}
                        :macro {:callers (with-leader "xe")}
                        :class {:methods (with-leader "xm")}
                        :prompt (with-leader "xi")}
                 :compile {:expr (with-leader "ce")
                           :toplevel_expr (with-leader "ct")
                           :file (with-leader "cf")}
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

(local sldb-mappings
       {:normal {:action "<CR>"
                 :details "d"
                 :frame {:toggle_details "d"
                         :source {:open "S"
                                  :open_split "<C-s>"
                                  :open_vsplit "<C-v>"
                                  :open_tab "<C-t>"}
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
                 :current_value {:send "s"
                                 :source "o"}
                 :inspected_value {:send "S"
                                   :source "O"
                                   :previous "<C-o>"
                                   :next "<C-i>"}
                 :next_field ["<Tab>" "<C-n>"]
                 :prev_field ["<S-Tab>" "<C-p"]
                 :refresh "R"}})

(local notes-mappings
       {:normal {:source {:open "<CR>"
                          :open_split "<C-s>"
                          :open_vsplit "<C-v>"
                          :open_tab "<C-t>"}}})

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
                 :prev_field ["<S-Tab>" "<C-p"]}})

(local mrepl-mappings
       {:normal {:clear (with-leader "C")
                 :disconnect (with-leader "D")}
        :insert {:space_arglist "<Space>"
                 :cr_arglist "<C-j>"
                 :submit "<CR>"
                 :interrupt "<C-c>"}})

(local xref-mappings
       {:normal {:source {:open "<CR>"
                          :open_split "<C-s>"
                          :open_vsplit "<C-v>"
                          :open_tab "<C-t>"}}})

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

(tset config :mappings (vim.tbl_deep_extend
                         "force"
                         default-mappings
                         vim.g.nvlime_mappings))

config
