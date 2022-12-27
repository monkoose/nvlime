local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_mrepl_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  km.buffer.insert("<Space>", "<Space><C-r>=nvlime#plugin#NvlimeKey('space')<CR>", "nvlime: Trigger the arglist hint")
  km.buffer.insert("<CR>", "<C-r>=nvlime#ui#mrepl#Submit()<CR>", "nvlime: Submit the last input to the REPL")
  km.buffer.insert("<C-j>\n                 ", "<CR><C-r>=nvlime#plugin#NvlimeKey('cr')<CR>", "nvlime: Insert a newline and trigger the arglist hint")
  km.buffer.insert("<C-c>\n                 ", "<C-r>=nvlime#ui#mrepl#Interrupt()<CR>", "nvlime: Interrupt the MREPL thread")
  km.buffer.normal((km.leader .. "C"), "<Cmd>call nvlime#ui#mrepl#Clear()<CR>", "nvlime: Clear the MREPL buffer")
  return km.buffer.normal((km.leader .. "D"), "<Cmd>call nvlime#ui#mrepl#Disconnect()<CR>", "nvlime: Disconnect from this REPL")
else
  return nil
end