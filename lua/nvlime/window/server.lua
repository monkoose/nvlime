local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local server = {}
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.server)
server.open = function(server_name)
  local bufnr = buffer["create-nolisted"](buffer["gen-name"](server_name), _2bfiletype_2b)
  local config = {height = 18, width = 100, noedit = true, title = (buffer.names.server .. " - " .. server_name)}
  return {window.center.open(bufnr, {}, config), bufnr}
end
return server