local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local ut = require("nvlime.utilities")
local disassembly = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.disassembly)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.disassembly)
local function content__3elines(content)
  local lines = ut["text->lines"](content)
  local height = 1
  local width = 0
  for idx, line in ipairs(lines) do
    height = (height + 1)
    local line_width = vim.fn.strdisplaywidth(line)
    if (line_width > width) then
      width = line_width
    else
    end
    lines[idx] = string.gsub(line, "^%s*;", "", 1)
  end
  table.insert(lines, 3, string.rep(vim.g.nvlime_horiz_sep, width))
  return {lines = lines, height = height, width = width}
end
disassembly.open = function(content)
  local text = content__3elines(content)
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  local config = {height = text.height, width = text.width, title = buffer.names.disassembly}
  return {window.center.open(bufnr, text.lines, config), bufnr}
end
return disassembly