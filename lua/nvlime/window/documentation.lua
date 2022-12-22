local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local documentation = {}
local _2bname_2b = "documentation"
local _2bbufname_2b = buffer["gen-name"](_2bname_2b)
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
documentation.open = function(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  return {window.cursor.open(bufnr, content, {title = _2bname_2b, similar = {"nvlime_description", "nvlime_macroexpand"}}), bufnr}
end
return documentation