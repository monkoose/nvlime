local km = require("nvlime.keymaps")
local km_globals = require("nvlime.keymaps.globals")
if not (vim.g.nvlime_disable_server_mappings or vim.g.nvlime_disable_mappings) then
  if not vim.g.nvlime_disable_global_mappings then
    km_globals.add(true, true)
  else
  end
  km.buffer.normal((km.leader .. "c"), "<Cmd>call nvlime#server#ConnectToCurServer()<CR>", "nvlime: Connect to this server")
  return km.buffer.normal((km.leader .. "s"), "<Cmd>call nvlime#server#StopCurServer()<CR>", "nvlime: Stop this server")
else
  return nil
end