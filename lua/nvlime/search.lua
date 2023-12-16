local _local_1_ = vim.api
local nvim_win_get_cursor = _local_1_["nvim_win_get_cursor"]
local nvim_win_set_cursor = _local_1_["nvim_win_set_cursor"]
local nvim_buf_get_lines = _local_1_["nvim_buf_get_lines"]
local nvim_buf_line_count = _local_1_["nvim_buf_line_count"]
local skip_groups = {"string", "character", "comment", "singlequote", "escape", "symbol"}
local search = {}
local function syntax_on_3f()
  return (vim.b.current_syntax ~= nil)
end
local function get_synname(synid)
  return string.lower(vim.fn.synIDattr(synid, "name"))
end
local function syn_ids(line, col)
  local synstack = vim.fn.synstack(line, col)
  local len = #synstack
  return {synstack[len], synstack[(len - 1)], synstack[(len - 2)]}
end
local function contains_any(str, strings)
  local result = false
  for _, pattern in ipairs(strings) do
    if result then break end
    if (string.find(str, pattern, 1, true) ~= nil) then
      result = true
    else
    end
  end
  return result
end
local function skip_region_3f(line, col)
  local result = false
  for _, synid in ipairs(syn_ids(line, col)) do
    if result then break end
    if contains_any(get_synname(synid), skip_groups) then
      result = true
    else
    end
  end
  return result
end
local function skip_by_region(line, col)
  if skip_region_3f(line, col) then
    return true
  else
    return false
  end
end
local function skip_same_paren(backward_3f)
  local count = 0
  local same_paren
  if backward_3f then
    same_paren = ")"
  else
    same_paren = "("
  end
  local inc_skip
  local function _6_()
    count = (count + 1)
    return true
  end
  inc_skip = _6_
  local dec_skip
  local function _7_()
    count = (count - 1)
    return true
  end
  dec_skip = _7_
  local function _8_(paren)
    if (paren == same_paren) then
      return inc_skip()
    else
      if (count == 0) then
        return false
      else
        return dec_skip()
      end
    end
  end
  return _8_
end
local function find_forward(text, pattern, init)
  local index, _, bracket = string.find(text, pattern, (init and (1 + init)))
  return index, bracket
end
local function find_backward(reversed_text, pattern, init)
  local len = (1 + #reversed_text)
  local index, bracket = find_forward(reversed_text, pattern, (init and (len - init)))
  if index then
    return (len - index), bracket
  else
    return nil
  end
end
local function get_lines(start, _end)
  local first = (start - 1)
  return nvim_buf_get_lines(0, first, _end, false)
end
local function forward_matches(pattern, line, col, _end, same_column_3f)
  local lines = get_lines(line, _end)
  local i = 1
  local text = lines[i]
  local index
  if same_column_3f then
    index = (col - 1)
  else
    index = col
  end
  local capture = nil
  local function _13_()
    while text do
      index, capture = find_forward(text, pattern, index)
      if index then
        local line_ = ((i - 1) + line)
        return line_, index, capture
      else
        i = (1 + i)
        text = lines[i]
      end
    end
    return nil
  end
  return _13_
end
local function backward_matches(pattern, line, col, start, same_column_3f)
  local lines = get_lines(start, line)
  local len = #lines
  local offset = (line - len)
  local reverse
  local function _15_(list, i)
    local str = list[i]
    if str then
      return str:reverse()
    else
      return nil
    end
  end
  reverse = _15_
  local i = len
  local index
  if same_column_3f then
    index = (1 + col)
  else
    index = col
  end
  local capture = nil
  local reversed_text = reverse(lines, i)
  local function _18_()
    while reversed_text do
      index, capture = find_backward(reversed_text, pattern, index)
      if index then
        local line_ = (offset + i)
        return line_, index, capture
      else
        i = (i - 1)
        reversed_text = reverse(lines, i)
      end
    end
    return nil
  end
  return _18_
end
search.top_form_line = function(backward_3f)
  local re = "^\\s*\\%($\\|;.*\\)\\n("
  local find_top
  local function _20_(flags)
    return vim.fn.search(re, flags)
  end
  find_top = _20_
  if backward_3f then
    return vim.fn.search(re, "bnW")
  else
    local stopline = vim.fn.search(re, "nW")
    if (stopline == 0) then
      return nvim_buf_line_count(0)
    else
      return stopline
    end
  end
end
search.pair_paren = function(line, col, opts)
  local o = (opts or {})
  local pattern = "([)(])"
  local stopline = (o.stopline or search.top_form_line(o.backward))
  local skip_paren = skip_same_paren(o.backward)
  local matches
  if o.backward then
    matches = backward_matches
  else
    matches = forward_matches
  end
  local skip
  local function _24_(l, c, paren)
    if skip_by_region(l, c) then
      return true
    else
      return skip_paren(paren)
    end
  end
  skip = _24_
  local result = nil
  for l, c, cap in matches(pattern, line, col, stopline, o["same-column?"]) do
    if result then break end
    if not skip(l, c, cap) then
      result = {l, c}
    else
    end
  end
  if result then
    return result
  else
    return {0, 0}
  end
end
return search