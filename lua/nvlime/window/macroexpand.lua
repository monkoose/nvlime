local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local macroexpand = {}
local _2bname_2b = "macroexpand"
local _2bbufname_2b = buffer["gen-name"](_2bname_2b)
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
macroexpand.open = function(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  return {window.cursor.open(bufnr, string.lower(content), {title = _2bname_2b, similar = {"nvlime_documentation", "nvlime_description"}}), bufnr}
end
return macroexpand