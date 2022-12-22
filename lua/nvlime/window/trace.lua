local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local trace = {}
local _2bname_2b = "trace"
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
trace.open = function(content, config)
  local bufnr = buffer["create-scratch"](buffer["gen-name"](config["conn-name"], _2bname_2b), _2bfiletype_2b)
  return {window.center.open(bufnr, content, {height = 15, width = 80, noedit = true, title = "trace dialog"}), bufnr}
end
return trace