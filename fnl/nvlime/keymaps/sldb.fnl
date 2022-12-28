(local km (require "nvlime.keymaps"))
(local sm km.mappings.sldb)

(local sldb {})

(fn sldb.add []
  (km.buffer.normal sm.normal.action
                    "<Cmd>call nvlime#ui#sldb#ChooseCurRestart()<CR>"
                    "nvlime: Choose a restart, toggle a frame or jump to the source code.")
  (km.buffer.normal sm.normal.details
                    "<Cmd>call nvlime#ui#sldb#ShowFrameDetails()<CR>"
                    "nvlime: Show the details of the frame under the cursor")
  (km.buffer.normal sm.normal.frame.source
                    "<Cmd>call nvlime#ui#sldb#OpenFrameSource()<CR>"
                    "nvlime: Open the source code for the frame under the cursor")
  (km.buffer.normal sm.normal.frame.source_split
                    "<Cmd>call nvlime#ui#sldb#OpenFrameSource('split')<CR>"
                    "nvlime: Open the source code for the frame under the cursor in a new split")
  (km.buffer.normal sm.normal.frame.source_vsplit
                    "<Cmd>call nvlime#ui#sldb#OpenFrameSource('vsplit')<CR>"
                    "nvlime: Open the source code for the frame under the cursor in a new vertical split")
  (km.buffer.normal sm.normal.frame.source_tab
                    "<Cmd>call nvlime#ui#sldb#OpenFrameSource('tabedit')<CR>"
                    "nvlime: Open the source code for the frame under the cursor in a new tabpage")
  (km.buffer.normal sm.normal.frame.restart
                    "<Cmd>call nvlime#ui#sldb#RestartCurFrame()<CR>"
                    "nvlime: Restart the frame under the cursor")
  (km.buffer.normal sm.normal.frame.eval_expr
                    "<Cmd>call nvlime#ui#sldb#EvalStringInCurFrame()<CR>"
                    "nvlime: Evaluate an expression in the frame under the cursor")
  (km.buffer.normal sm.normal.frame.send_expr
                    "<Cmd>call nvlime#ui#sldb#SendValueInCurFrameToREPL()<CR>"
                    "nvlime: Evaluate an expression in the frame under the cursor and send the result to the REPL")
  (km.buffer.normal sm.normal.frame.disassemble
                    "<Cmd>call nvlime#ui#sldb#DisassembleCurFrame()<CR>"
                    "nvlime: Disassemble the frame under the cursor")
  (km.buffer.normal sm.normal.frame.return_result
                    "<Cmd>call nvlime#ui#sldb#ReturnFromCurFrame()<CR>"
                    "nvlime: Return a manually specified result from the frame under the cursor") 
  (km.buffer.normal sm.normal.frame.step
                    "<Cmd>call nvlime#ui#sldb#StepCurOrLastFrame('step')<CR>"
                    "nvlime: Start stepping in the frame under the cursor")
  (km.buffer.normal sm.normal.local_var.source
                    "<Cmd>call nvlime#ui#sldb#FindSource()<CR>"
                    "nvlime: Open the source code for a local variable")
  (km.buffer.normal sm.normal.local_var.inspect
                    "<Cmd>call nvlime#ui#sldb#InspectVarInCurFrame()<CR>"
                    "nvlime: Inspect a variable in the frame under the cursor")
  (km.buffer.normal sm.normal.step_over
                    "<Cmd>call nvlime#ui#sldb#StepCurOrLastFrame('next')<CR>"
                    "nvlime: Step over the current function call")
  (km.buffer.normal sm.normal.step_out
                    "<Cmd>call nvlime#ui#sldb#StepCurOrLastFrame('out')<CR>"
                    "nvlime: Step out of the current function")
  (km.buffer.normal sm.normal.abort
                    "<Cmd>call b:nvlime_conn.SLDBAbort()<CR>"
                    "nvlime: Invoke the restart labeled ABORT")
  (km.buffer.normal sm.normal.continue
                    "<Cmd>call b:nvlime_conn.SLDBContinue()<CR>"
                    "nvlime: Invoke the restart labeled CONTINUE")
  (km.buffer.normal sm.normal.inspect_condition
                    "<Cmd>call nvlime#ui#sldb#InspectCurCondition()<CR>"
                    "nvlime: Inspect the current condition object"))

sldb
