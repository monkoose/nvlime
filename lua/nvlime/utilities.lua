local psl = require("parsley")
local _local_1_ = vim.api
local nvim_win_set_cursor = _local_1_["nvim_win_set_cursor"]
local nvim_win_get_cursor = _local_1_["nvim_win_get_cursor"]
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
  local _let_5_ = coord.begin
  local begin_l = _let_5_[1]
  local begin_c = _let_5_[2]
  local _let_6_ = coord["end"]
  local end_l = _let_6_[1]
  local end_c = _let_6_[2]
  return begin_l, begin_c, end_l, end_c
end
local function in_coord_range_3f(coord, linenr, col)
  local begin_l, begin_c, end_l, end_c = coord_range(coord)
  if ((end_l >= linenr) and (linenr >= begin_l)) then
    if ((linenr == begin_l) and (begin_l == end_l)) then
      return ((end_c >= col) and (col >= begin_c))
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
  local _let_9_ = nvim_win_get_cursor(winid)
  local linenr = _let_9_[1]
  local col_0 = _let_9_[2]
  return {linenr, (col_0 + 1)}
end
local function set_win_cursor(winid, pos)
  local linenr = psl.first(pos)
  local col_0 = (psl.second(pos) - 1)
  return nvim_win_set_cursor(winid, {linenr, col_0})
end
local function find_if(pred, list)
  local result = nil
  for _, item in ipairs(list) do
    if result then break end
    if pred(item) then
      result = item
    else
    end
  end
  return result
end
return {["text->lines"] = text__3elines, echo = echo, ["echo-warning"] = echo_warning, ["echo-error"] = echo_error, ["plist->table"] = plist__3etable, ["calc-lines-size"] = calc_lines_size, ["get-win-cursor"] = get_win_cursor, ["set-win-cursor"] = set_win_cursor, ["in-coord-range?"] = in_coord_range_3f, ["find-if"] = find_if}