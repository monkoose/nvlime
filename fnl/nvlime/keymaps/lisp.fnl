(local km (require "nvlime.keymaps"))
(local lm km.mappings.lisp)
(local repl (require "nvlime.window.main.repl"))

(local lisp {})

(fn lisp.add []
  (km.buffer.insert lm.insert.space_arglist
                    "<Space><C-r>=nvlime#plugin#NvlimeKey('space')<CR>"
                    "nvlime: Trigger the arglist hint")
  (km.buffer.insert lm.insert.cr_arglist
                    "<CR><C-r>=nvlime#plugin#NvlimeKey('cr')<CR>"
                    "nvlime: Trigger the arglist hint")

  (km.buffer.normal lm.normal.interaction_mode
                    "<Cmd>call nvlime#plugin#InteractionMode()<CR>"
                    "nvlime: Toggle interaction mode")
  (km.buffer.normal lm.normal.load_file
                    "<Cmd>call nvlime#plugin#LoadFile(nvim_buf_get_name(0))<CR>"
                    "nvlime: Load the current file")
  (km.buffer.normal lm.normal.disassemble.expr
                    "<Cmd>call nvlime#plugin#DisassembleForm(nvlime#ui#CurExpr())<CR>"
                    "nvlime: Disassemble the form under the cursor")
  (km.buffer.normal lm.normal.disassemble.symbol
                    "<Cmd>call nvlime#plugin#DisassembleForm(nvlime#ui#CurSymbol())<CR>"
                    "nvlime: Disassemble the form under the cursor")
  (km.buffer.normal lm.normal.set_package
                    "<Cmd>call nvlime#plugin#SetPackage()<CR>"
                    "nvlime: Specify the package for the current buffer")
  (km.buffer.normal lm.normal.set_breakpoint
                    "<Cmd>call nvlime#plugin#SetBreakpoint()<CR>"
                    "nvlime: Set a breakpoint at entry to a function")
  (km.buffer.normal lm.normal.show_threads
                    "<Cmd>call nvlime#plugin#ListThreads()<CR>"
                    "nvlime: Show a list of the running threads")

  (km.buffer.normal lm.normal.connection.new
                    "<Cmd>call nvlime#plugin#ConnectREPL()<CR>"
                    "nvlime: Connect to a server")
  (km.buffer.normal lm.normal.connection.switch
                    "<Cmd>call nvlime#plugin#SelectCurConnection()<CR>"
                    "nvlime: Switch connections")
  (km.buffer.normal lm.normal.connection.close
                    "<Cmd>call nvlime#plugin#CloseCurConnection()<CR>"
                    "nvlime: Disconnect the current connection")
  (km.buffer.normal lm.normal.connection.rename
                    "<Cmd>call nvlime#plugin#RenameCurConnection()<CR>"
                    "nvlime: Rename the current connection")

  (km.buffer.normal lm.normal.server.new
                    "<Cmd>call nvlime#server#New(v:true, get(g:, 'nvlime_cl_use_terminal', v:false))<CR>"
                    "nvlime: Run a new server and connect to it")
  (km.buffer.normal lm.normal.server.show
                    "<Cmd>call nvlime#plugin#ShowCurrentServer()<CR>"
                    "nvlime: View the console outpot of the current server")
  (km.buffer.normal lm.normal.server.show_selected
                    "<Cmd>call nvlime#plugin#ShowSelectedServer()<CR>"
                    "nvlime: Show a list of the servers and view the console output of the chosen one")
  (km.buffer.normal lm.normal.server.stop
                    "<Cmd>call nvlime#plugin#StopCurrentServer()<CR>"
                    "nvlime: Stop the current server")
  (km.buffer.normal lm.normal.server.stop_selected
                    "<Cmd>call nvlime#plugin#StopSelectedServer()<CR>"
                    "nvlime: Show a list of the servers and stop the chosen one")
  (km.buffer.normal lm.normal.server.rename
                    "<Cmd>call nvlime#plugin#RenameSelectedServer()<CR>"
                    "nvlime: Rename a server")
  (km.buffer.normal lm.normal.server.restart
                    "<Cmd>call nvlime#plugin#RestartCurrentServer()<CR>"
                    "nvlime: Restart the current server")

  ;;; TODO repl show
  (km.buffer.normal lm.normal.repl.clear
                    #(repl.clear)
                    "nvlime: Clear the REPL buffer")
  (km.buffer.normal lm.normal.repl.send_atom_expr
                    "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurExprOrAtom())<CR>"
                    "nvlime: Send the expression/atom under the cursor to the REPL")
  (km.buffer.normal lm.normal.repl.send_atom
                    "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Send the atom under the cursor to the REPL")
  (km.buffer.normal lm.normal.repl.send_expr
                    "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurExpr())<CR>"
                    "nvlime: Send the expression under the cursor to the REPL")
  (km.buffer.normal lm.normal.repl.send_toplevel_expr
                    "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurTopExpr())<CR>"
                    "nvlime: Send the top-level expression under the cursor to the REPL")
  (km.buffer.normal lm.normal.repl.prompt
                    "<Cmd>call nvlime#plugin#SendToREPL()<CR>"
                    "nvlime: Send a snippet to the REPL")
  (km.buffer.visual lm.visual.repl.send_selection
                    "<Cmd>call nvlime#plugin#SendToREPL(nvlime#ui#CurSelection())<CR>"
                    "nvlime: Send the current selection to the REPL")

  (km.buffer.normal lm.normal.macro.expand
                    "<Cmd>call nvlime#plugin#ExpandMacro(nvlime#ui#CurExpr(), 'expand')<CR>"
                    "nvlime: Expand the macro under the cursor")
  (km.buffer.normal lm.normal.macro.expand_once
                    "<Cmd>call nvlime#plugin#ExpandMacro(nvlime#ui#CurExpr(), 'one')<CR>"
                    "nvlime: Expand the macro under the cursor once")
  (km.buffer.normal lm.normal.macro.expand_all
                    "<Cmd>call nvlime#plugin#ExpandMacro(nvlime#ui#CurExpr(), 'all')<CR>"
                    "nvlime: Expand the macro under the cursor and all nested macros")

  (km.buffer.normal lm.normal.compile.expr
                    "<Cmd>call nvlime#plugin#Compile(nvlime#ui#CurExpr(v:true))<CR>"
                    "nvlime: Compile the expression under the cursor")
  (km.buffer.normal lm.normal.compile.toplevel_expr
                    "<Cmd>call nvlime#plugin#Compile(nvlime#ui#CurTopExpr(v:true))<CR>"
                    "nvlime: Compile the top-level expression under the cursor")
  (km.buffer.normal lm.normal.compile.file
                    "<Cmd>call nvlime#plugin#CompileFile(nvim_buf_get_name(0))<CR>"
                    "nvlime: Compile the current file")
  (km.buffer.visual lm.visual.compile.selection
                    "<Cmd>call nvlime#plugin#Compile(nvlime#ui#CurSelection(v:true))<CR>"
                    "nvlime: Compile the current selection")

  (km.buffer.normal lm.normal.xref.function.callers
                    "<Cmd>call nvlime#plugin#XRefSymbol('CALLS', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show callers of the function under the cursor")
  (km.buffer.normal lm.normal.xref.function.callees
                    "<Cmd>call nvlime#plugin#XRefSymbol('CALLS-WHO', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show callees of the function under the cursor")
  (km.buffer.normal lm.normal.xref.symbol.references
                    "<Cmd>call nvlime#plugin#XRefSymbol('REFERENCES', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show references to the variable under the cursor")
  (km.buffer.normal lm.normal.xref.symbol.bindings
                    "<Cmd>call nvlime#plugin#XRefSymbol('BINDS', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show bindings for the variable under the cursor")
  (km.buffer.normal lm.normal.xref.symbol.definition
                    "<Cmd>call nvlime#plugin#FindDefinition(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show the definition for the symbol under the cursor")
  (km.buffer.normal lm.normal.xref.symbol.set_locations
                    "<Cmd>call nvlime#plugin#XRefSymbol('SETS', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show locations where the variable under the cursor is set")
  (km.buffer.normal lm.normal.xref.macro.callers
                    "<Cmd>call nvlime#plugin#XRefSymbol('MACROEXPANDS', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show locations where the macro under the cursor is called")
  (km.buffer.normal lm.normal.xref.class.methods
                    "<Cmd>call nvlime#plugin#XRefSymbol('SPECIALIZES', nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show specialized methods for the class under the cursor")
  (km.buffer.normal lm.normal.xref.prompt
                    "<Cmd>call nvlime#plugin#XRefSymbolWrapper()<CR>"
                    "nvlime: Interactively prompt for the symbol to search for cross references")

  (km.buffer.normal lm.normal.describe.operator
                    "<Cmd>call nvlime#plugin#DescribeSymbol(nvlime#ui#CurOperator())<CR>"
                    "nvlime: Describe the operator of the expression under the cursor")
  (km.buffer.normal lm.normal.describe.atom
                    "<Cmd>call nvlime#plugin#DescribeSymbol(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Describe the atom under the cursor")
  (km.buffer.normal lm.normal.describe.prompt
                    "<Cmd>call nvlime#plugin#DescribeSymbol()<CR>"
                    "nvlime: Prompt for the symbol to describe")
  (km.buffer.normal lm.normal.apropos.prompt
                    "<Cmd>call nvlime#plugin#AproposList()<CR>"
                    "nvlime: Apropos search")
  (km.buffer.normal lm.normal.arglist.show
                    "<Cmd>call nvlime#plugin#ShowOperatorArgList(nvlime#ui#CurOperator())<CR>"
                    "nvlime: Show the arglist for the expression under the cursor")
  (km.buffer.normal lm.normal.documentation.operator
                    "<Cmd>call nvlime#plugin#DocumentationSymbol(nvlime#ui#CurOperator())<CR>"
                    "nvlime: Show the documentation for the operator of the expression under the cursor")
  (km.buffer.normal lm.normal.documentation.atom
                    "<Cmd>call nvlime#plugin#DocumentationSymbol(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Show the documentation for the atom under the cursor")
  (km.buffer.normal lm.normal.documentation.prompt
                    "<Cmd>call nvlime#plugin#DocumentationSymbol()<CR>"
                    "nvlime: Prompt for a symbol and show its documentation")

  (km.buffer.normal lm.normal.inspect.atom_expr
                    "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurExprOrAtom())<CR>"
                    "nvlime: Evaluate the expression/atom under the cursor and inspect the result")
  (km.buffer.normal lm.normal.inspect.atom
                    "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Evaluate the atom under the cursor and inspect the result")
  (km.buffer.normal lm.normal.inspect.expr
                    "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurExpr())<CR>"
                    "nvlime: Evaluate the expression under the cursor and inspect the result")
  (km.buffer.normal lm.normal.inspect.toplevel_expr
                    "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurTopExpr())<CR>"
                    "nvlime: Evaluate the top-level expression under the cursor and inspect the result")
  (km.buffer.normal lm.normal.inspect.symbol
                    "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurSymbol())<CR>"
                    "nvlime: Inspect the symbol under the cursor")
  (km.buffer.normal lm.normal.inspect.prompt
                    "<Cmd>call nvlime#plugin#Inspect()<CR>"
                    "nvlime: Evaluate a snippet and inspect the result")
  (km.buffer.visual lm.visual.inspect.selection
                    "<Cmd>call nvlime#plugin#Inspect(nvlime#ui#CurSelection())<CR>"
                    "nvlime: Evaluate the current selection and inspect the result")

  (km.buffer.normal lm.normal.trace.show
                    "<Cmd>call nvlime#plugin#OpenTraceDialog()<CR>"
                    "nvlime: Show the trace dialog")
  (km.buffer.normal lm.normal.trace.toggle
                    "<Cmd>call nvlime#plugin#DialogToggleTrace(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Trace/untrace the function under the cursor")
  (km.buffer.normal lm.normal.trace.prompt
                    "<Cmd>call nvlime#plugin#DialogToggleTrace()<CR>"
                    "nvlime: Prompt for a function name to trace/untrace")

  (km.buffer.normal lm.normal.undefine.function
                    "<Cmd>call nvlime#plugin#UndefineFunction(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Undefine the function under the cursor")
  (km.buffer.normal lm.normal.undefine.symbol
                    "<Cmd>call nvlime#plugin#UninternSymbol(nvlime#ui#CurAtom())<CR>"
                    "nvlime: Unintern the symbol under the cursor")
  (km.buffer.normal lm.normal.undefine.prompt
                    "<Cmd>call nvlime#plugin#UndefineUninternWrapper()<CR>"
                    "nvlime: Interactively prompt for the function to undefine or symbol to unintern"))

lisp
