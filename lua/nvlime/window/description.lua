local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local describe = {}
local _2bname_2b = "description"
local _2bbufname_2b = buffer["gen-name"](_2bname_2b)
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
describe.open = function(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  return {window.cursor.open(bufnr, content, {title = _2bname_2b, similar = {"nvlime_documentation", "nvlime_macroexpand"}}), bufnr}
end
return describe