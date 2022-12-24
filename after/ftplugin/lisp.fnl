(local km (require "nvlime.keymaps"))
(local window (require "nvlime.window"))
(local repl (require "nvlime.window.main.repl"))
(local km-window (require "nvlime.window.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))

;; So that indentexpr is actually used
(vim.api.nvim_buf_set_option 0 "lisp" false)

(vim.cmd "syntax match SpellIgnore /\\<u\\+\\>/ contains=@NoSpell")

(when (not vim.g.nvlime_disable_mappings)
  (if vim.b.nvlime_input
      (do
        (when (not vim.g.nvlime_disable_global_mappings)
          (km-globals.add true true))
      ;; input buffers
        (when (not vim.g.nvlime_disable_input_mappings)
          (km.buffer.insert "<F1>"
                            #(km-window.toggle)
                            "Show keymaps help")
          (km.buffer.insert "<CR>"
                            "<Cmd>call nvlime#ui#input#FromBufferComplete()<CR>"
                            "nvlime: Complete the input")
          (km.buffer.normal "<CR>"
                            "<Cmd>call nvlime#ui#input#FromBufferComplete()<CR>"
                            "nvlime: Complete the input")
          (km.buffer.insert "<C-n>"
                            "<Cmd>call nvlime#ui#input#NextHistoryItem()<CR>"
                            "nvlime: Show the previous item in input history")
          (km.buffer.insert "<C-p>"
                            "<Cmd>call nvlime#ui#input#NextHistoryItem(v:false)<CR>"
                            "nvlime: Show the next item in input history")
          (km.buffer.insert "<Esc>"
                            #(let [[linenr col] (vim.api.nvim_win_get_cursor 0)]
                               (if (and (= linenr 1) (= col 0))
                                   (vim.api.nvim_win_close 0 true))
                               (km.feedkeys "<Esc>"))
                            "Close window or leave insert mode")))
      ; ; lisp buffers
      (do
        (when (not vim.g.nvlime_disable_global_mappings)
          (km-globals.add false false))
        (km.buffer.normal "q<Esc>"
                          #(window.close_last_float)
                          "Closes last opened floating window")
        (km.buffer.insert "<Space>"
                          "<Space><C-r>=nvlime#plugin#NvlimeKey('space')<CR>"
                          "nvlime: Trigger the arglist hint")
        (km.buffer.insert "<CR>"
                          "<CR><C-r>=nvlime#plugin#NvlimeKey('cr')<CR>"
                          "nvlime: Trigger the arglist hint")

        (km.buffer.normal (.. km.leader "<CR>")
                          "<Cmd>call nvlime#plugin#InteractionMode()<CR>"
                          "nvlime: Toggle interaction mode")
        (km.buffer.normal (.. km.leader "l")
                          "<Cmd>call nvlime#plugin#LoadFile(nvim_buf_get_name(0))<CR>"
                          "nvlime: Load the current file")
        (km.buffer.normal (.. km.leader "a")
                          "<Cmd>call nvlime#plugin#DisassembleForm(nvlime#ui#CurExpr())<CR>"
                          "nvlime: Disassemble the form under the cursor")
        (km.buffer.normal (.. km.leader "p")
                          "<Cmd>call nvlime#plugin#SetPackage()<CR>"
                          "nvlime: Specify the package for the current buffer")
        (km.buffer.normal (.. km.leader "b")
                          "<Cmd>call nvlime#plugin#SetBreakpoint()<CR>"
                          "nvlime: Set a breakpoint at entry to a function")
        (km.buffer.normal (.. km.leader "T")
                          "<Cmd>call nvlime#plugin#ListThreads()<CR>"
                          "nvlime: Show a list of the running threads")

        (km.buffer.normal (.. km.leader "cc")
                          "<Cmd>call nvlime#plugin#ConnectREPL()<CR>"
                          "nvlime: Connect to a server")
        (km.buffer.normal (.. km.leader "cs")
                          "<Cmd>call nvlime#plugin#SelectCurConnection()<CR>"
                          "nvlime: Switch connections")
        (km.buffer.normal (.. km.leader "cd")
                          "<Cmd>call nvlime#plugin#CloseCurConnection()<CR>"
                          "nvlime: Disconnect the current connection")
        (km.buffer.normal (.. km.leader "cR")
                          "<Cmd>call nvlime#plugin#RenameCurConnection()<CR>"
                          "nvlime: Rename the current connection")

        (km.buffer.normal (.. km.leader "rr")
                          "<Cmd>call nvlime#server#New(v:true, get(g:, 'nvlime_cl_use_terminal', v:false))<CR>"
                          "nvlime: Run a new server and connect to it")
        (km.buffer.normal (.. km.leader "rv")
                          "<Cmd>call nvlime#plugin#ShowCurrentServer()<CR>"
                          "nvlime: View the console outpot of the current server")
        (km.buffer.normal (.. km.leader "rV")
                          "<Cmd>call nvlime#plugin#ShowSelectedServer()<CR>"
                          "nvlime: Show a list of the servers and view the console output of the chosen one")
        (km.buffer.normal (.. km.leader "rs")
                          "<Cmd>call nvlime#plugin#StopCurrentServer()<CR>"
                          "nvlime: Stop the current server")
        (km.buffer.normal (.. km.leader "rS")
                          "<Cmd>call nvlime#plugin#StopSelectedServer()<CR>"
                          "nvlime: Show a list of the servers and stop the chosen one")
        (km.buffer.normal (.. km.leader "rR")
                          "<Cmd>call nvlime#plugin#RenameSelectedServer()<CR>"
                          "nvlime: Rename a server")
        (km.buffer.normal (.. km.leader "rt")
                          "<Cmd>call nvlime#plugin#RestartCurrentServer()<CR>"
                          "nvlime: Restart the current server")
        (km.buffer.normal (.. km.leader "rc") #(repl.clear)
                          "nvlime: Clear the REPL buffer")

        (km.buffer.normal (.. km.leader "ss")
                          "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurExprOrAtom())<CR>"
                          "nvlime: Send the expression/atom under the cursor to the REPL")
        (km.buffer.normal (.. km.leader "se")
                          "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurExp())<CR>"
                          "nvlime: Send the expression under the cursor to the REPL")
        (km.buffer.normal (.. km.leader "st")
                          "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurTopExpr())<CR>"
                          "nvlime: Send the top-level expression under the cursor to the REPL")
        (km.buffer.normal (.. km.leader "sa")
                          "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Send the atom under the cursor to the REPL")
        (km.buffer.normal (.. km.leader "si")
                          "<Cmd>call nvlime#plugin#SendToREPL()<CR>"
                          "nvlime: Send a snippet to the REPL")
        (km.buffer.visual (.. km.leader "s")
                          "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurSelection())<CR>"
                          "nvlime: Send the current selection to the REPL")

        (km.buffer.normal (.. km.leader "mm")
                          "<Cmd>call nvlime#plugin#ExpandMacro(nvlime#ui#CurExpr(), 'expand')<CR>"
                          "nvlime: Expand the macro under the cursor")
        (km.buffer.normal (.. km.leader "m1")
                          "<Cmd>call nvlime#plugin#ExpandMacro(nvlime#ui#CurExpr(), 'one')<CR>"
                          "nvlime: Expand the macro under the cursor once")
        (km.buffer.normal (.. km.leader "ma")
                          "<Cmd>call nvlime#plugin#ExpandMacro(nvlime#ui#CurExpr(), 'all')<CR>"
                          "nvlime: Expand the macro under the cursor and all nested macros")

        (km.buffer.normal (.. km.leader "ce")
                          "<Cmd>call nvlime#plugin#Compile(nvlime#ui#CurExpr(v:true))<CR>"
                          "nvlime: Compile the expression under the cursor")
        (km.buffer.normal (.. km.leader "ct")
                          "<Cmd>call nvlime#plugin#Compile(nvlime#ui#CurTopExpr(v:true))<CR>"
                          "nvlime: Compile the top-level expression under the cursor")
        (km.buffer.normal (.. km.leader "cf")
                          "<Cmd>call nvlime#plugin#CompileFile(nvim_buf_get_name(0))<CR>"
                          "nvlime: Compile the current file")
        (km.buffer.visual (.. km.leader "c")
                          "<Cmd>call nvlime#plugin#Compile(nvlime#ui#CurSelection(v:true))<CR>"
                          "nvlime: Compile the current selection")

        (km.buffer.normal (.. km.leader "xc")
                          "<Cmd>call nvlime#plugin#XRefSymbol('CALLS', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show callers of the function under the cursor")
        (km.buffer.normal (.. km.leader "xC")
                          "<Cmd>call nvlime#plugin#XRefSymbol('CALLS-WHO', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show callees of the function under the cursor")
        (km.buffer.normal (.. km.leader "xr")
                          "<Cmd>call nvlime#plugin#XRefSymbol('REFERENCES', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show references to the variable under the cursor")
        (km.buffer.normal (.. km.leader "xb")
                          "<Cmd>call nvlime#plugin#XRefSymbol('BINDS', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show bindings for the variable under the cursor")
        (km.buffer.normal (.. km.leader "xs")
                          "<Cmd>call nvlime#plugin#XRefSymbol('SETS', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show locations where the variable under the cursor is set")
        (km.buffer.normal (.. km.leader "xe")
                          "<Cmd>call nvlime#plugin#XRefSymbol('MACROEXPANDS', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show locations where the macro under the cursor is called")
        (km.buffer.normal (.. km.leader "xm")
                          "<Cmd>call nvlime#plugin#XRefSymbol('SPECIALIZES', nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show specialized methods for the class under the cursor")
        (km.buffer.normal (.. km.leader "xd")
                          "<Cmd>call nvlime#plugin#FindDefinition(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show the definition for the symbol under the cursor")
        (km.buffer.normal (.. km.leader "xi")
                          "<Cmd>call nvlime#plugin#XRefSymbolWrapper()<CR>"
                          "nvlime: Interactively prompt for the symbol to search for cross references")

        (km.buffer.normal (.. km.leader "do")
                          "<Cmd>call nvlime#plugin#DescribeSymbol(nvlime#ui#CurOperator())<CR>"
                          "nvlime: Describe the operator of the expression under the cursor")
        (km.buffer.normal (.. km.leader "da")
                          "<Cmd>call nvlime#plugin#DescribeSymbol(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Describe the atom under the cursor")
        (km.buffer.normal (.. km.leader "di")
                          "<Cmd>call nvlime#plugin#DescribeSymbol()<CR>"
                          "nvlime: Prompt for the symbol to describe")
        (km.buffer.normal (.. km.leader "ds")
                          "<Cmd>call nvlime#plugin#AproposList()<CR>"
                          "nvlime: Apropos search")
        (km.buffer.normal (.. km.leader "ddo")
                          "<Cmd>call nvlime#plugin#DocumentationSymbol(nvlime#ui#CurOperator())<CR>"
                          "nvlime: Show the documentation for the operator of the expression under the cursor")
        (km.buffer.normal (.. km.leader "dda")
                          "<Cmd>call nvlime#plugin#DocumentationSymbol(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show the documentation for the atom under the cursor")
        (km.buffer.normal "K"
                          "<Cmd>call nvlime#plugin#DocumentationSymbol(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Show the documentation for the atom under the cursor")
        (km.buffer.normal (.. km.leader "ddi")
                          "<Cmd>call nvlime#plugin#DocumentationSymbol()<CR>"
                          "nvlime: Prompt for a symbol and show its documentation")
        (km.buffer.normal (.. km.leader "dr")
                          "<Cmd>call nvlime#plugin#ShowOperatorArgList(nvlime#ui#CurOperator())<CR>"
                          "nvlime: Show the arglist for the expression under the cursor")

        (km.buffer.normal (.. km.leader "ii")
                          "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurExprOrAtom())<CR>"
                          "nvlime: Evaluate the expression/atom under the cursor and inspect the result")
        (km.buffer.normal (.. km.leader "ie")
                          "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurExpr())<CR>"
                          "nvlime: Evaluate the expression under the cursor and inspect the result")
        (km.buffer.normal (.. km.leader "it")
                          "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurTopExpr())<CR>"
                          "nvlime: Evaluate the top-level expression under the cursor and inspect the result")
        (km.buffer.normal (.. km.leader "ia")
                          "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Evaluate the atom under the cursor and inspect the result")
        (km.buffer.normal (.. km.leader "is")
                          "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurSymbol())<CR>"
                          "nvlime: Inspect the symbol under the cursor")
        (km.buffer.normal (.. km.leader "in")
                          "<Cmd>call nvlime#plugin#Inspect()<CR>"
                          "nvlime: Evaluate a snippet and inspect the result")
        (km.buffer.visual (.. km.leader "i")
                          "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurSelection())<CR>"
                          "nvlime: Evaluate the current selection and inspect the result")

        (km.buffer.normal (.. km.leader "td")
                          "<Cmd>call nvlime#plugin#OpenTraceDialog()<CR>"
                          "nvlime: Show the trace dialog")
        (km.buffer.normal (.. km.leader "tt")
                          "<Cmd>call nvlime#plugin#DialogToggleTrace(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Trace/untrace the function under the cursor")
        (km.buffer.normal (.. km.leader "ti")
                          "<Cmd>call nvlime#plugin#DialogToggleTrace()<CR>"
                          "nvlime: Prompt for a function name to trace/untrace")

        (km.buffer.normal (.. km.leader "uf")
                          "<Cmd>call nvlime#plugin#UndefineFunction(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Undefine the function under the cursor")
        (km.buffer.normal (.. km.leader "us")
                          "<Cmd>call nvlime#plugin#UninternSymbol(nvlime#ui#CurAtom())<CR>"
                          "nvlime: Unintern the symbol under the cursor")
        (km.buffer.normal (.. km.leader "ui")
                          "<Cmd>call nvlime#plugin#UndefineUninternWrapper()<CR>"
                          "nvlime: Interactively prompt for the function to undefine or symbol to unintern"))))
