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
local function echo(str, level)
  return vim.notify(("nvlime: " .. str), (level or vim.log.levels.INFO))
end
local function echo_warning(str)
  return echo(str, vim.log.levels.WARN)
end
local function echo_error(str)
  return echo(str, vim.log.levels.ERROR)
end
local function coord_range(coord)
  local _let_4_ = coord.begin
  local begin_l = _let_4_[1]
  local begin_c = _let_4_[2]
  local _let_5_ = coord["end"]
  local end_l = _let_5_[1]
  local end_c = _let_5_[2]
  return begin_l, begin_c, end_l, end_c
end
local function in_coord_range_3f(coord, linenr, col)
  local begin_l, begin_c, end_l, end_c = coord_range(coord)
  if (function(_6_,_7_,_8_) return (_6_ >= _7_) and (_7_ >= _8_) end)(end_l,linenr,begin_l) then
    if (function(_9_,_10_,_11_) return (_9_ == _10_) and (_10_ == _11_) end)(linenr,begin_l,end_l) then
      return (function(_12_,_13_,_14_) return (_12_ >= _13_) and (_13_ >= _14_) end)(end_c,col,begin_c)
    elseif (linenr == begin_l) then
      return (col >= begin_c)
    elseif (linenr == end_l) then
      return (col <= end_c)
    else
      return true
    end
  else
    return false
  end
end
local function get_win_cursor(winid)
  local _let_17_ = vim.api.nvim_win_get_cursor(winid)
  local linenr = _let_17_[1]
  local col_0 = _let_17_[2]
  return {linenr, (col_0 + 1)}
end
local function set_win_cursor(winid, pos)
  local linenr = psl.first(pos)
  local col_0 = (psl.second(pos) - 1)
  return vim.api.nvim_win_set_cursor(winid, {linenr, col_0})
end
return {["text->lines"] = text__3elines, echo = echo, ["echo-warning"] = echo_warning, ["echo-error"] = echo_error, ["plist->table"] = plist__3etable, ["calc-lines-size"] = calc_lines_size, ["get-win-cursor"] = get_win_cursor, ["set-win-cursor"] = set_win_cursor, ["in-coord-range?"] = in_coord_range_3f}