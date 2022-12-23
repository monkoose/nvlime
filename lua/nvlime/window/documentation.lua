local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local documentation = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.documentation)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.documentation)
documentation.open = function(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  return {window.cursor.open(bufnr, content, {title = buffer.names.documentation, similar = {"nvlime_description", "nvlime_macroexpand"}}), bufnr}
end
return documentation