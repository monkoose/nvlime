local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_sldb_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(false, false)
  else
  end
  km.buffer.normal("<CR>", "<Cmd>call nvlime#ui#sldb#ChooseCurRestart()<CR>", "nvlime: Choose a restart, toggle a frame or jump to the source code.")
  km.buffer.normal("d", "<Cmd>call nvlime#ui#sldb#ShowFrameDetails()<CR>", "nvlime: Show the details of the frame under the cursor")
  km.buffer.normal("S", "<Cmd>call nvlime#ui#sldb#OpenFrameSource()<CR>", "nvlime: Open the source code for the frame under the cursor")
  km.buffer.normal("<C-s>", "<Cmd>call nvlime#ui#sldb#OpenFrameSource('split')<CR>", "nvlime: Open the source code for the frame under the cursor in a new split")
  km.buffer.normal("<C-v>", "<Cmd>call nvlime#ui#sldb#OpenFrameSource('vsplit')<CR>", "nvlime: Open the source code for the frame under the cursor in a new vertical split")
  km.buffer.normal("<C-t>", "<Cmd>call nvlime#ui#sldb#OpenFrameSource('tabedit')<CR>", "nvlime: Open the source code for the frame under the cursor in a new tabpage")
  km.buffer.normal("O", "<Cmd>call nvlime#ui#sldb#FindSource()<CR>", "nvlime: Open the source code for a local variable")
  km.buffer.normal("r", "<Cmd>call nvlime#ui#sldb#RestartCurFrame()<CR>", "nvlime: Restart the frame under the cursor")
  km.buffer.normal("s", "<Cmd>call nvlime#ui#sldb#StepCurOrLastFrame('step')<CR>", "nvlime: Start stepping in the frame under the cursor")
  km.buffer.normal("x", "<Cmd>call nvlime#ui#sldb#StepCurOrLastFrame('next')<CR>", "nvlime: Step over the current function call")
  km.buffer.normal("o", "<Cmd>call nvlime#ui#sldb#StepCurOrLastFrame('out')<CR>", "nvlime: Step out of the current function")
  km.buffer.normal("c", "<Cmd>call b:nvlime_conn.SLDBContinue()<CR>", "nvlime: Invoke the restart labeled CONTINUE")
  km.buffer.normal("a", "<Cmd>call b:nvlime_conn.SLDBAbort()<CR>", "nvlime: Invoke the restart labeled ABORT")
  km.buffer.normal("C", "<Cmd>call nvlime#ui#sldb#InspectCurCondition()<CR>", "nvlime: Inspect the current condition object")
  km.buffer.normal("i", "<Cmd>call nvlime#ui#sldb#InspectVarInCurFrame()<CR>", "nvlime: Inspect a variable in the frame under the cursor")
  km.buffer.normal("e", "<Cmd>call nvlime#ui#sldb#EvalStringInCurFrame()<CR>", "nvlime: Evaluate an expression in the frame under the cursor")
  km.buffer.normal("E", "<Cmd>call nvlime#ui#sldb#SendValueInCurFrameToREPL()<CR>", "nvlime: Evaluate an expression in the frame under the cursor and send the result to the REPL")
  km.buffer.normal("D", "<Cmd>call nvlime#ui#sldb#DisassembleCurFrame()<CR>", "nvlime: Disassemble the frame under the cursor")
  return km.buffer.normal("R", "<Cmd>call nvlime#ui#sldb#ReturnFromCurFrame()<CR>", "nvlime: Return a manually specified result from the frame under the cursor")
else
  return nil
end