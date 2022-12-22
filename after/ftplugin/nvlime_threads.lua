local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_threads_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  km.buffer.normal("<C-c>", "<Cmd>call nvlime#ui#threads#InterruptCurThread()<CR>", "nvlime: Interrupt the selected thread")
  km.buffer.normal("K", "<Cmd>call nvlime#ui#threads#KillCurThread()<CR>", "nvlime: Kill the selected thread")
  km.buffer.normal("D", "<Cmd>call nvlime#ui#threads#DebugCurThread()<CR>", "nvlime: Invoke the debugger in the selected thread")
  return km.buffer.normal("r", "<Cmd>call nvlime#ui#threads#Refresh()<CR>", "nvlime: Refresh the thread list")
else
  return nil
end