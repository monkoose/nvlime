local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local macroexpand = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.macroexpand)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.macroexpand)
macroexpand.open = function(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  return {window.cursor.open(bufnr, string.lower(content), {title = buffer.names.macroexpand, similar = {"nvlime_documentation", "nvlime_description"}}), bufnr}
end
return macroexpand