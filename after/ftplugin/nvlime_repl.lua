local km = require("nvlime.keymaps")
local repl = require("nvlime.window.main.repl")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_repl_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, false)
  else
  end
  km.buffer.normal("<C-c>", "<Cmd>call b:nvlime_conn.Interrupt({'name': 'REPL-THREAD', 'package': 'KEYWORD'})<CR>", "nvlime: Interrupt the REPL thread")
  km.buffer.normal("i", "<Cmd>call nvlime#ui#repl#InspectCurREPLPresentation()<CR>", "nvlime: Insect the evaluation result under the cursor")
  km.buffer.normal("y", "<Cmd>call nvlime#ui#repl#YankCurREPLPresentation()<CR>", "nvlime: Yank the evaluation result under the cursor")
  local function _2_()
    return repl.clear()
  end
  km.buffer.normal("C", _2_, "nvlime: Clear the REPL buffer")
  km.buffer.normal("<Tab>", "<Cmd>call nvlime#ui#repl#NextField(v:true)<CR>", "nvlime: Move the cursor to the next presented object")
  km.buffer.normal("<C-n>", "<Cmd>call nvlime#ui#repl#NextField(v:true)<CR>", "nvlime: Move the cursor to the next presented object")
  km.buffer.normal("<S-Tab>", "<Cmd>call nvlime#ui#repl#NextField(v:false)<CR>", "nvlime: Move the cursor to the next presented object")
  return km.buffer.normal("<C-p>", "<Cmd>call nvlime#ui#repl#NextField(v:false)<CR>", "nvlime: Move the cursor to the next presented object")
else
  return nil
end