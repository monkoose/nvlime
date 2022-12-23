local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local trace = {}
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.trace)
trace.open = function(content, config)
  local bufnr = buffer["create-scratch"](buffer["gen-name"](config["conn-name"], buffer.names.trace), _2bfiletype_2b)
  return {window.center.open(bufnr, content, {height = 15, width = 80, noedit = true, title = "trace dialog"}), bufnr}
end
return trace