local buffer = require("nvlime.buffer")
local ut = require("nvlime.utilities")
local pbuf = require("parsley.buffer")
local pwin = require("parsley.window")
local options = require("nvlime.config")
local _local_1_ = vim.api
local nvim_buf_line_count = _local_1_["nvim_buf_line_count"]
local nvim_buf_get_name = _local_1_["nvim_buf_get_name"]
local nvim_win_set_option = _local_1_["nvim_win_set_option"]
local nvim_win_get_option = _local_1_["nvim_win_get_option"]
local nvim_win_get_buf = _local_1_["nvim_win_get_buf"]
local nvim_win_set_cursor = _local_1_["nvim_win_set_cursor"]
local nvim_win_set_config = _local_1_["nvim_win_set_config"]
local nvim_win_close = _local_1_["nvim_win_close"]
local nvim_win_get_var = _local_1_["nvim_win_get_var"]
local nvim_win_set_var = _local_1_["nvim_win_set_var"]
local nvim_win_set_buf = _local_1_["nvim_win_set_buf"]
local nvim_get_current_buf = _local_1_["nvim_get_current_buf"]
local nvim_get_current_win = _local_1_["nvim_get_current_win"]
local nvim_set_current_win = _local_1_["nvim_set_current_win"]
local nvim_tabpage_list_wins = _local_1_["nvim_tabpage_list_wins"]
local nvim_create_autocmd = _local_1_["nvim_create_autocmd"]
local nvim_clear_autocmds = _local_1_["nvim_clear_autocmds"]
local nvim_exec = _local_1_["nvim_exec"]
local nvim_open_win = _local_1_["nvim_open_win"]
local window = {cursor = {}, center = {}}
local _2bscrollbar_bufname_2b = buffer["gen-name"]("scrollbar")
local _2afocus_winid_2a = 1000
local function filetype_win(filetypes)
  local found_winid = nil
  for _, winid in ipairs(nvim_tabpage_list_wins(0)) do
    if found_winid then break end
    local bufnr = nvim_win_get_buf(winid)
    local buf_ft = pbuf.filetype(bufnr)
    for _0, ft in ipairs(filetypes) do
      if found_winid then break end
      if (buf_ft == ft) then
        found_winid = winid
      else
      end
    end
  end
  return found_winid
end
window["set-opt"] = function(winid, opt, value)
  return nvim_win_set_option(winid, opt, value)
end
window["set-opts"] = function(winid, opts)
  for opt, val in pairs(opts) do
    nvim_win_set_option(winid, opt, val)
  end
  return nil
end
window["set-minimal-style-options"] = function(winid)
  return window["set-opts"](winid, {wrap = true, signcolumn = "no", list = false, number = false, relativenumber = false, spell = false})
end
window["find-horiz-pos"] = function(req_height, scr_row, scr_height)
  local border_len = 3
  local bot_height = (scr_height - scr_row - border_len)
  local top_height = (scr_row - border_len)
  local bottom_3f = ((bot_height > req_height) or (bot_height > top_height))
  if bottom_3f then
    return true, math.min(bot_height, req_height)
  else
    return false, math.min(top_height, req_height)
  end
end
window["update-win-options"] = function(winid, opts, focus_3f)
  nvim_win_set_cursor(winid, {1, 0})
  if pwin["floating?"](winid) then
    nvim_win_set_config(winid, opts)
  else
  end
  if focus_3f then
    return nvim_set_current_win(winid)
  else
    return nil
  end
end
local function win_nvlime_ft_3f(winid)
  local pattern = "nvlime_"
  return (nil ~= string.find(pwin.filetype(winid), pattern))
end
local function main_win_3f(winid)
  local win_ft = pwin.filetype(winid)
  local result = false
  for _, ft in ipairs({"nvlime_repl", "nvlime_sldb", "nvlime_notes"}) do
    if result then break end
    if (win_ft == ft) then
      result = true
    else
    end
  end
  return result
end
window["close-when"] = function(predicate)
  for _, winid in ipairs(nvim_tabpage_list_wins(0)) do
    if predicate(winid) then
      nvim_win_close(winid, true)
    else
    end
  end
  return nil
end
window.close_all = function()
  local function _8_(_241)
    return win_nvlime_ft_3f(_241)
  end
  return window["close-when"](_8_)
end
window.close_all_except_main = function()
  local function _9_(_241)
    return (win_nvlime_ft_3f(_241) and not main_win_3f(_241))
  end
  return window["close-when"](_9_)
end
window["last-float"] = function()
  local win_list = nvim_tabpage_list_wins(0)
  local function _10_(_241, _242)
    return (_241 > _242)
  end
  table.sort(win_list, _10_)
  local result = nil
  for _, winid in ipairs(win_list) do
    if result then break end
    if (pwin["floating?"](winid) and not pcall(nvim_win_get_var, winid, "nvlime_scrollbar")) then
      result = winid
    else
    end
  end
  return result
end
window["last-float-except-current"] = function()
  local float_id = window["last-float"]()
  if (float_id ~= nvim_get_current_win()) then
    return float_id
  else
    return nil
  end
end
window.close_last_float = function()
  local last_float_winid = window["last-float-except-current"]()
  if last_float_winid then
    nvim_win_close(last_float_winid, true)
    return last_float_winid
  else
    return nil
  end
end
window.scroll_float = function(step, reverse_3f)
  local last_float_winid = window["last-float-except-current"]()
  if last_float_winid then
    do
      local wininfo = pwin["get-info"](last_float_winid)
      local old_scrolloff = nvim_win_get_option(last_float_winid, "scrolloff")
      local set_float_cursor
      local function _14_(_241)
        return nvim_win_set_cursor(last_float_winid, {_241, 0})
      end
      set_float_cursor = _14_
      window["set-opt"](last_float_winid, "scrolloff", 0)
      if reverse_3f then
        local expected_line = (wininfo.topline - step)
        if (expected_line < 1) then
          set_float_cursor(1)
        else
          set_float_cursor(expected_line)
        end
      else
        local expected_line = (wininfo.botline + step)
        local last_line = nvim_buf_line_count(nvim_win_get_buf(last_float_winid))
        if (expected_line > last_line) then
          set_float_cursor(last_line)
        else
          set_float_cursor(expected_line)
        end
      end
      window["set-opt"](last_float_winid, "scrolloff", old_scrolloff)
    end
    return last_float_winid
  else
    return nil
  end
end
window.split = function(winid, bufnr, cmd)
  local bufhidden = buffer["get-opt"](bufnr, "bufhidden")
  buffer["set-opts"](bufnr, {bufhidden = "hide"})
  nvim_set_current_win(winid)
  nvim_exec((cmd .. " " .. nvim_buf_get_name(bufnr)), false)
  buffer["set-opts"](bufnr, {bufhidden = bufhidden})
  return nvim_get_current_win()
end
window.split_focus = function(cmd)
  if pwin["visible?"](_2afocus_winid_2a) then
    return window.split(_2afocus_winid_2a, nvim_get_current_buf(), cmd)
  else
    return ut["echo-warning"]("Can't split this window.")
  end
end
local function create_scrollbar_buffer(icon)
  local _20_, _21_ = pbuf["exists?"](_2bscrollbar_bufname_2b)
  if ((_20_ == true) and (nil ~= _21_)) then
    local bufnr = _21_
    return bufnr
  else
    local _ = _20_
    local bufnr = buffer.create(_2bscrollbar_bufname_2b)
    local function _22_()
      local tbl_18_auto = {}
      local i_19_auto = 0
      for _0 = 1, 100 do
        local val_20_auto = icon
        if (nil ~= val_20_auto) then
          i_19_auto = (i_19_auto + 1)
          do end (tbl_18_auto)[i_19_auto] = val_20_auto
        else
        end
      end
      return tbl_18_auto
    end
    buffer["fill!"](bufnr, _22_())
    return bufnr
  end
end
local function scrollbar_required_3f(wininfo, content_height)
  return (wininfo.height < content_height)
end
local function calc_scrollbar_height(wininfo, content_height)
  return math.max(math.floor(((wininfo.height / content_height) * wininfo.height)), 1)
end
local function calc_scrollbar_offset(wininfo, buf_height, scrollbar_height)
  return math.min((wininfo.height - scrollbar_height), math.ceil((((wininfo.topline - 1) / buf_height) * wininfo.height)))
end
local function add_scrollbar(wininfo, zindex)
  local scrollbar_winid = -1
  local scrollbar_bufnr = create_scrollbar_buffer("\226\150\140")
  local pattern = tostring(wininfo.winid)
  local close_scrollbar
  local function _25_()
    if pwin["visible?"](scrollbar_winid) then
      return nvim_win_close(scrollbar_winid, true)
    else
      return nil
    end
  end
  close_scrollbar = _25_
  local callback
  local function _27_()
    local info = pwin["get-info"](wininfo.winid)
    local content_height = nvim_buf_line_count(info.bufnr)
    if (pwin["floating?"](info.winid) and scrollbar_required_3f(info, content_height)) then
      local scrollbar_height = calc_scrollbar_height(info, content_height)
      local scrollbar_offset = calc_scrollbar_offset(info, content_height, scrollbar_height)
      local update_sb_window
      local function _28_()
        return nvim_win_set_config(scrollbar_winid, {relative = "win", win = info.winid, height = scrollbar_height, row = scrollbar_offset, col = info.width})
      end
      update_sb_window = _28_
      local open_sb_window
      local function _29_()
        scrollbar_winid = nvim_open_win(scrollbar_bufnr, false, {relative = "win", win = info.winid, width = 1, height = scrollbar_height, row = scrollbar_offset, col = info.width, zindex = (zindex + 1), style = "minimal", focusable = false})
        window["set-opts"](scrollbar_winid, {winhighlight = "Normal:FloatBorder"})
        return nvim_win_set_var(scrollbar_winid, "nvlime_scrollbar", true)
      end
      open_sb_window = _29_
      if pwin["visible?"](scrollbar_winid) then
        return update_sb_window()
      else
        return open_sb_window()
      end
    else
      return close_scrollbar()
    end
  end
  callback = _27_
  nvim_create_autocmd("BufModifiedSet", {buffer = wininfo.bufnr, callback = callback})
  nvim_create_autocmd("WinScrolled", {pattern = pattern, callback = callback})
  local function _32_()
    close_scrollbar()
    nvim_clear_autocmds({event = {"WinClosed", "WinScrolled"}, pattern = pattern})
    return nvim_clear_autocmds({event = "BufModifiedSet", buffer = wininfo.bufnr})
  end
  nvim_create_autocmd("WinClosed", {pattern = pattern, nested = true, callback = _32_})
  local function _33_()
    if pwin["visible?"](wininfo.winid) then
      return callback()
    else
      return nil
    end
  end
  nvim_create_autocmd("WinScrolled", {pattern = tostring(_2afocus_winid_2a), callback = _33_, once = true})
  local function _35_()
    return callback()
  end
  vim.defer_fn(_35_, 5)
  return scrollbar_winid
end
window["open-float"] = function(bufnr, opts, close_on_leave_3f, focus_3f, callback)
  local cur_winid = nvim_get_current_win()
  if not pwin["floating?"](cur_winid) then
    _2afocus_winid_2a = cur_winid
  else
  end
  local zindex
  do
    local _37_ = window["last-float"]()
    if (_37_ == nil) then
      zindex = 42
    elseif (nil ~= _37_) then
      local id = _37_
      zindex = (pwin["get-zindex"](id) + 2)
    else
      zindex = nil
    end
  end
  local winid = nvim_open_win(bufnr, focus_3f, vim.tbl_extend("keep", opts, {style = "minimal", border = options.floating_window.border, zindex = zindex}))
  add_scrollbar(pwin["get-info"](winid), pwin["get-zindex"](winid))
  if close_on_leave_3f then
    local function _39_()
      return window["close-float"](winid)
    end
    nvim_create_autocmd("WinLeave", {buffer = bufnr, callback = _39_, nested = true, once = true})
  else
  end
  window["set-minimal-style-options"](winid)
  if callback then
    callback(winid, bufnr)
  else
  end
  return winid
end
window["close-float"] = function(winid)
  if (pwin["visible?"](winid) and pwin["floating?"](winid)) then
    return nvim_win_close(winid, true)
  else
    return nil
  end
end
window.cursor["calc-opts"] = function(config)
  local _let_43_ = pwin["get-screen-size"]()
  local scr_height = _let_43_[1]
  local scr_width = _let_43_[2]
  local _let_44_ = ut["calc-lines-size"](config.lines)
  local text_height = _let_44_[1]
  local text_width = _let_44_[2]
  local width = math.min((scr_width - 4), text_width)
  local _let_45_ = pwin["get-screen-pos"]()
  local scr_row = _let_45_[1]
  local _ = _let_45_[2]
  local bot_3f, height = window["find-horiz-pos"](text_height, scr_row, scr_height)
  local row
  if bot_3f then
    row = 1
  else
    row = 0
  end
  local _47_
  if bot_3f then
    _47_ = "NW"
  else
    _47_ = "SW"
  end
  return {relative = "cursor", row = row, col = -1, width = width, height = height, anchor = _47_, title = (" " .. config.title .. " "), title_pos = "center"}
end
window.cursor.callback = function(winid)
  local cur_bufnr = nvim_get_current_buf()
  local function _49_()
    return window["close-float"](winid)
  end
  return nvim_create_autocmd({"CursorMoved", "InsertEnter"}, {buffer = cur_bufnr, callback = _49_, nested = true, once = true})
end
window.cursor.open = function(bufnr, content, config)
  local lines = ut["text->lines"](content)
  local opts = window.cursor["calc-opts"]({lines = lines, title = config.title})
  buffer["fill!"](bufnr, lines)
  local _50_, _51_ = pbuf["visible?"](bufnr)
  if ((_50_ == true) and (nil ~= _51_)) then
    local winid = _51_
    window["update-win-options"](winid, opts, pwin["floating?"](winid))
    return winid
  else
    local _ = _50_
    local _52_, _53_ = filetype_win(config.similar)
    if ((_52_ == true) and (nil ~= _53_)) then
      local winid = _53_
      nvim_win_set_buf(winid, bufnr)
      window["update-win-options"](winid, opts)
      return winid
    else
      local _0 = _52_
      local function _54_(_241)
        return window.cursor.callback(_241)
      end
      return window["open-float"](bufnr, opts, true, false, _54_)
    end
  end
end
local function calc_optimal_size(content_size, min, max, gap)
  return math.min(math.abs((max - gap)), math.max(content_size, min))
end
window.center["calc-pos"] = function(max, side, gap)
  return ((max - side - gap) * 0.5)
end
window.center["calc-opts"] = function(args)
  local _let_57_ = pwin["get-screen-size"]()
  local scr_height = _let_57_[1]
  local scr_width = _let_57_[2]
  local _let_58_ = ut["calc-lines-size"](args.lines)
  local text_height = _let_58_[1]
  local text_width = _let_58_[2]
  local gap = 6
  local width = calc_optimal_size(text_width, args.width, scr_width, (gap + 4))
  local height = calc_optimal_size(text_height, args.height, scr_height, gap)
  return {relative = "editor", width = width, height = height, row = window.center["calc-pos"](scr_height, height, 3), col = window.center["calc-pos"](scr_width, width, 3), title = (" " .. args.title .. " "), title_pos = "center", focusable = not args.nofocusable}
end
window.center.open = function(bufnr, content, config, callback)
  local lines = ut["text->lines"](content)
  local opts_table = {lines = lines, height = config.height, width = config.width, title = config.title}
  local opts = window.center["calc-opts"](opts_table)
  if not config.noedit then
    buffer["fill!"](bufnr, lines)
  else
  end
  local _60_, _61_ = pbuf["visible?"](bufnr)
  if ((_60_ == true) and (nil ~= _61_)) then
    local winid = _61_
    window["update-win-options"](winid, opts, true)
    return winid
  else
    local _ = _60_
    local winid = window["open-float"](bufnr, opts, true, true, callback)
    nvim_win_set_cursor(winid, {1, 0})
    return winid
  end
end
return window