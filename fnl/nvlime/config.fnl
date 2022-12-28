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

(local
  default-opts
  {:leader "<LocalLeader>"
   :implementation "sbcl"
   :address {:host "127.0.0.1"
             :port 7002}
   :connect_timeout -1
   :compiler_policy nil
   :indent_keywords default-indent-keywords
   :input_history_limit 100
   :contribs default-contribs
   ;; this option doesn't work for now
   ;; because it requires vim funcrefs
   :user_contrib_initializers nil
   :autodoc {:enabled false
             :max_level 5
             :max_lines 50}
   :main_window {:position "right"
                 :size ""}
   :floating_window {:border "single"
                     :scroll_step 3}
   :cmp {:enabled false}
   :arglist {:enabled true}})

(vim.tbl_deep_extend "force"
                     default-opts
                     (or vim.g.nvlime_config {}))
