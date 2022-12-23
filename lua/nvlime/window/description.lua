local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local description = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.description)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.description)
description.open = function(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  return {window.cursor.open(bufnr, content, {title = buffer.names.description, similar = {"nvlime_documentation", "nvlime_macroexpand"}}), bufnr}
end
return description