local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_inspector_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  km.buffer.normal("<CR>", "<Cmd>call nvlime#ui#inspector#InspectorSelect()<CR>", "nvlime: Activate the interactable field/button under the cursor")
  km.buffer.normal("s", "<Cmd>call nvlime#ui#inspector#SendCurValueToREPL()<CR>", "nvlime: Send the value of the field under the cursor to the REPL")
  km.buffer.normal("S", "<Cmd>call nvlime#ui#inspector#SendCurInspecteeToREPL()<CR>", "nvlime: Send the value being inspected to the REPL")
  km.buffer.normal("o", "<Cmd>call nvlime#ui#inspector#FindSource('part')<CR>", "nvlime: Open the source code for the value of the field under the cursor")
  km.buffer.normal("O", "<Cmd>call nvlime#ui#inspector#FindSource('inspectee')<CR>", "nvlime: Open the source code for the value being inspected")
  km.buffer.normal("<Tab>", "<Cmd>call nvlime#ui#inspector#NextField(v:true)<CR>", "nvlime: Select the next interactable field/button")
  km.buffer.normal("<C-n>", "<Cmd>call nvlime#ui#inspector#NextField(v:true)<CR>", "nvlime: Select the next interactable field/button")
  km.buffer.normal("<S-Tab>", "<Cmd>call nvlime#ui#inspector#NextField(v:false)<CR>", "nvlime: Select the previous interactable field/button")
  km.buffer.normal("<C-p>", "<Cmd>call nvlime#ui#inspector#NextField(v:false)<CR>", "nvlime: Select the previous interactable field/button")
  km.buffer.normal("p", "<Cmd>call nvlime#ui#inspector#InspectorPop()<CR>", "nvlime: Return to the previous inspected object")
  km.buffer.normal("n", "<Cmd>call nvlime#ui#inspector#InspectorNext()<CR>", "nvlime: Move to the next inspected object")
  return km.buffer.normal("R", "<Cmd>call b:nvlime_conn.InspectorReinspect({c, r -> c.ui.OnInspect(c, r, v:null, v:null)})<CR>", "nvlime: Refresh the inspector")
else
  return nil
end