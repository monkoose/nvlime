local psl = require("parsley")
local function text__3elines(text)
  if text then
    if psl["string?"](text) then
      return vim.split(text, "\n", {trimempty = true})
    else
      return text
    end
  else
    return {}
  end
end
local function calc_lines_size(lines)
  local width = 0
  local height = 0
  for _, line in ipairs(lines) do
    local line_width = vim.fn.strdisplaywidth(line)
    height = (height + 1)
    if (line_width > width) then
      width = line_width
    else
    end
  end
  return {height, width}
end
local function plist__3etable(plist)
  local t = {}
  for i = 1, #plist, 2 do
    t[plist[i].name] = plist[(i + 1)]
  end
  return t
end
local function echo(str)
  return psl.echo({"nvlime: ", "String"}, {str, "WarningMsg"})
end
return {["text->lines"] = text__3elines, echo = echo, ["plist->table"] = plist__3etable, ["calc-lines-size"] = calc_lines_size}