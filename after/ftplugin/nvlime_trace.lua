local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_trace_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  km.buffer.normal("<CR>", "<Cmd>call nvlime#ui#trace_dialog#Select()<CR>", "nvlime: Activate the interactable field/button under the cursor")
  km.buffer.normal("i", "<Cmd>call nvlime#ui#trace_dialog#Select('inspect')<CR>", "nvlime: Inspect the value of the field under the cursor")
  km.buffer.normal("s", "<Cmd>call nvlime#ui#trace_dialog#Select('to_repl')<CR>", "nvlime: Send the value of the field under the cursor to the REPL")
  km.buffer.normal("R", "<Cmd>call nvlime#plugin#OpenTraceDialog()<CR>", "nvlime: Refresh the trace dialog")
  km.buffer.normal("<Tab>", "<Cmd>call nvlime#ui#trace_dialog#NextField(v:true)<CR>", "nvlime: Select the next interactable field/button")
  km.buffer.normal("<C-n>", "<Cmd>call nvlime#ui#trace_dialog#NextField(v:true)<CR>", "nvlime: Select the next interactable field/button")
  km.buffer.normal("<S-Tab>", "<Cmd>call nvlime#ui#trace_dialog#NextField(v:false)<CR>", "nvlime: Select the previous interactable field/button")
  return km.buffer.normal("<C-p>", "<Cmd>call nvlime#ui#trace_dialog#NextField(v:false)<CR>", "nvlime: Select the previous interactable field/button")
else
  return nil
end