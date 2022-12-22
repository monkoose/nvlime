local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local server = {}
local _2bname_2b = "server"
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
server.open = function(server_name)
  local bufnr = buffer["create-nolisted"](buffer["gen-name"](server_name), _2bfiletype_2b)
  local config = {height = 18, width = 100, noedit = true, title = (_2bname_2b .. " - " .. server_name)}
  return {window.center.open(bufnr, {}, config), bufnr}
end
return server