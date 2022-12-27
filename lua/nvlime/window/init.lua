local buffer = require("nvlime.buffer")
local ut = require("nvlime.utilities")
local psl_buf = require("parsley.buffer")
local psl_win = require("parsley.window")
local window = {cursor = {}, center = {}}
local _2bfloat_border_2b = (vim.g.nvlime_border or "single")
local _2bscrollbar_bufname_2b = buffer["gen-name"]("scrollbar")
local _2afocus_winid_2a = 1000
local function visible_ft_3f(filetypes)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local buf_ft = psl_buf.filetype(bufnr)
    for _0, ft in ipairs(filetypes) do
      if (buf_ft == ft) then
        return true, winid
      else
      end
    end
  end
  return nil
end
window["set-opts"] = function(winid, opts)
  for opt, val in pairs(opts) do
    vim.api.nvim_win_set_option(winid, opt, val)
  end
  return nil
end
window["set-minimal-style-options"] = function(winid)
  return window["set-opts"](winid, {wrap = true, signcolumn = "no", list = false, spell = false, number = false, relativenumber = false})
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
window["update-win-options"] = function(winid, opts, _3ffocus_3f)
  vim.api.nvim_win_set_cursor(winid, {1, 0})
  if psl_win["floating?"](winid) then
    vim.api.nvim_win_set_config(winid, opts)
  else
  end
  if _3ffocus_3f then
    return vim.api.nvim_set_current_win(winid)
  else
    return nil
  end
end
local function win_buf_nvlime_ft_3f(winid)
  local pattern = "nvlime_"
  return string.find(psl_win.filetype(winid), pattern)
end
local function main_win_3f(winid)
  for _, ft in ipairs({"nvlime_repl", "nvlime_sldb", "nvlime_notes"}) do
    if (psl_win.filetype(winid) == ft) then
      return true
    else
    end
  end
  return nil
end
window["close-when"] = function(predicate)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if predicate(winid) then
      vim.api.nvim_win_close(winid, true)
    else
    end
  end
  return nil
end
window.close_all = function()
  local function _7_(_241)
    return win_buf_nvlime_ft_3f(_241)
  end
  return window["close-when"](_7_)
end
window.close_all_except_main = function()
  local function _8_(_241)
    return (win_buf_nvlime_ft_3f(_241) and not main_win_3f(_241))
  end
  return window["close-when"](_8_)
end
window["last-float"] = function()
  local win_list = vim.api.nvim_tabpage_list_wins(0)
  local function _9_(_241, _242)
    return (_241 > _242)
  end
  table.sort(win_list, _9_)
  for _, winid in ipairs(win_list) do
    if (psl_win["floating?"](winid) and not pcall(vim.api.nvim_win_get_var, winid, "nvlime_scrollbar")) then
      return winid
    else
    end
  end
  return nil
end
window["last-float-except-current"] = function()
  local float_id = window["last-float"]()
  if (float_id == vim.api.nvim_get_current_win()) then
    return nil
  else
    return float_id
  end
end
window.close_last_float = function()
  local last_float_winid = window["last-float-except-current"]()
  if last_float_winid then
    vim.api.nvim_win_close(last_float_winid, true)
    return last_float_winid
  else
    return nil
  end
end
window.scroll_float = function(step, reverse_3f)
  local last_float_winid = window["last-float-except-current"]()
  if last_float_winid then
    do
      local wininfo = psl_win["get-info"](last_float_winid)
      local old_scrolloff = vim.api.nvim_win_get_option(last_float_winid, "scrolloff")
      local set_float_cursor
      local function _13_(_241)
        return vim.api.nvim_win_set_cursor(last_float_winid, {_241, 0})
      end
      set_float_cursor = _13_
      vim.api.nvim_win_set_option(last_float_winid, "scrolloff", 0)
      if reverse_3f then
        local expected_line = (wininfo.topline - step)
        if (expected_line < 1) then
          set_float_cursor(1)
        else
          set_float_cursor(expected_line)
        end
      else
        local expected_line = (wininfo.botline + step)
        local last_line = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(last_float_winid))
        if (expected_line > last_line) then
          set_float_cursor(last_line)
        else
          set_float_cursor(expected_line)
        end
      end
      vim.api.nvim_win_set_option(last_float_winid, "scrolloff", old_scrolloff)
    end
    return last_float_winid
  else
    return nil
  end
end
window.split = function(winid, bufnr, cmd)
  local bufhidden = vim.api.nvim_buf_get_option(bufnr, "bufhidden")
  buffer["set-opts"](bufnr, {bufhidden = "hide"})
  vim.api.nvim_set_current_win(winid)
  vim.api.nvim_exec((cmd .. " " .. vim.api.nvim_buf_get_name(bufnr)), false)
  buffer["set-opts"](bufnr, {bufhidden = bufhidden})
  return vim.api.nvim_get_current_win()
end
window.split_focus = function(cmd)
  if psl_win["visible?"](_2afocus_winid_2a) then
    return window.split(_2afocus_winid_2a, vim.api.nvim_get_current_buf(), cmd)
  else
    return ut.echo("Can't split this window.")
  end
end
local function create_scrollbar_buffer(icon)
  local _19_, _20_ = psl_buf["exists?"](_2bscrollbar_bufname_2b)
  if ((_19_ == true) and (nil ~= _20_)) then
    local bufnr = _20_
    return bufnr
  elseif true then
    local _ = _19_
    local bufnr = buffer.create(_2bscrollbar_bufname_2b)
    local function _21_()
      local tbl_17_auto = {}
      local i_18_auto = #tbl_17_auto
      for _0 = 1, 100 do
        local val_19_auto = icon
        if (nil ~= val_19_auto) then
          i_18_auto = (i_18_auto + 1)
          do end (tbl_17_auto)[i_18_auto] = val_19_auto
        else
        end
      end
      return tbl_17_auto
    end
    buffer["fill!"](bufnr, _21_())
    return bufnr
  else
    return nil
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
  local function _24_()
    if psl_win["visible?"](scrollbar_winid) then
      return vim.api.nvim_win_close(scrollbar_winid, true)
    else
      return nil
    end
  end
  close_scrollbar = _24_
  local callback
  local function _26_()
    local info = psl_win["get-info"](wininfo.winid)
    local content_height = vim.api.nvim_buf_line_count(info.bufnr)
    if (psl_win["floating?"](info.winid) and scrollbar_required_3f(info, content_height)) then
      local scrollbar_height = calc_scrollbar_height(info, content_height)
      local scrollbar_offset = calc_scrollbar_offset(info, content_height, scrollbar_height)
      if psl_win["visible?"](scrollbar_winid) then
        return vim.api.nvim_win_set_config(scrollbar_winid, {relative = "win", win = info.winid, height = scrollbar_height, row = scrollbar_offset, col = info.width})
      else
        scrollbar_winid = vim.api.nvim_open_win(scrollbar_bufnr, false, {relative = "win", win = info.winid, width = 1, height = scrollbar_height, row = scrollbar_offset, col = info.width, zindex = (zindex + 1), style = "minimal", focusable = false})
        window["set-opts"](scrollbar_winid, {winhighlight = "Normal:FloatBorder"})
        return vim.api.nvim_win_set_var(scrollbar_winid, "nvlime_scrollbar", true)
      end
    else
      return close_scrollbar()
    end
  end
  callback = _26_
  vim.api.nvim_create_autocmd("BufModifiedSet", {buffer = wininfo.bufnr, callback = callback})
  vim.api.nvim_create_autocmd("WinScrolled", {pattern = pattern, callback = callback})
  local function _29_()
    close_scrollbar()
    vim.api.nvim_clear_autocmds({event = {"WinClosed", "WinScrolled"}, pattern = pattern})
    return vim.api.nvim_clear_autocmds({event = "BufModifiedSet", buffer = wininfo.bufnr})
  end
  vim.api.nvim_create_autocmd("WinClosed", {pattern = pattern, nested = true, callback = _29_})
  local function _30_()
    if psl_win["visible?"](wininfo.winid) then
      return callback()
    else
      return nil
    end
  end
  vim.api.nvim_create_autocmd("WinScrolled", {pattern = tostring(_2afocus_winid_2a), callback = _30_, once = true})
  local function _32_()
    return callback()
  end
  vim.defer_fn(_32_, 5)
  return scrollbar_winid
end
window["open-float"] = function(bufnr, opts, close_on_leave_3f, focus_3f, _3fcallback)
  local cur_winid = vim.api.nvim_get_current_win()
  if not psl_win["floating?"](cur_winid) then
    _2afocus_winid_2a = cur_winid
  else
  end
  local zindex
  do
    local _34_ = window["last-float"]()
    if (_34_ == nil) then
      zindex = 42
    elseif (nil ~= _34_) then
      local id = _34_
      zindex = (psl_win["get-zindex"](id) + 2)
    else
      zindex = nil
    end
  end
  local winid = vim.api.nvim_open_win(bufnr, focus_3f, vim.tbl_extend("keep", opts, {style = "minimal", border = _2bfloat_border_2b, zindex = zindex}))
  add_scrollbar(psl_win["get-info"](winid), psl_win["get-zindex"](winid))
  if close_on_leave_3f then
    local function _36_()
      return window["close-float"](winid)
    end
    vim.api.nvim_create_autocmd("WinLeave", {buffer = bufnr, callback = _36_, nested = true, once = true})
  else
  end
  window["set-minimal-style-options"](winid)
  if _3fcallback then
    _3fcallback(winid, bufnr)
  else
  end
  return winid
end
window["close-float"] = function(winid)
  if (psl_win["visible?"](winid) and psl_win["floating?"](winid)) then
    return vim.api.nvim_win_close(winid, true)
  else
    return nil
  end
end
window.cursor["calc-opts"] = function(config)
  local _let_40_ = psl_win["get-screen-size"]()
  local scr_height = _let_40_[1]
  local scr_width = _let_40_[2]
  local _let_41_ = ut["calc-lines-size"](config.lines)
  local text_height = _let_41_[1]
  local text_width = _let_41_[2]
  local width = math.min((scr_width - 4), text_width)
  local _let_42_ = psl_win["get-screen-pos"]()
  local scr_row = _let_42_[1]
  local _ = _let_42_[2]
  local bot_3f, height = window["find-horiz-pos"](text_height, scr_row, scr_height)
  local row
  if bot_3f then
    row = 1
  else
    row = 0
  end
  local _44_
  if bot_3f then
    _44_ = "NW"
  else
    _44_ = "SW"
  end
  return {relative = "cursor", row = row, col = -1, width = width, height = height, anchor = _44_, title = (" " .. config.title .. " "), title_pos = "center"}
end
window.cursor.callback = function(winid)
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local function _46_()
    return window["close-float"](winid)
  end
  return vim.api.nvim_create_autocmd({"CursorMoved", "InsertEnter"}, {buffer = cur_bufnr, callback = _46_, nested = true, once = true})
end
window.cursor.open = function(bufnr, content, config)
  local lines = ut["text->lines"](content)
  local opts = window.cursor["calc-opts"]({lines = lines, title = config.title})
  buffer["fill!"](bufnr, lines)
  local _47_, _48_ = psl_buf["visible?"](bufnr)
  if ((_47_ == true) and (nil ~= _48_)) then
    local winid = _48_
    window["update-win-options"](winid, opts, psl_win["floating?"](winid))
    return winid
  elseif true then
    local _ = _47_
    local _49_, _50_ = visible_ft_3f(config.similar)
    if ((_49_ == true) and (nil ~= _50_)) then
      local winid = _50_
      vim.api.nvim_win_set_buf(winid, bufnr)
      window["update-win-options"](winid, opts)
      return winid
    elseif true then
      local _0 = _49_
      local function _51_(_241)
        return window.cursor.callback(_241)
      end
      return window["open-float"](bufnr, opts, true, false, _51_)
    else
      return nil
    end
  else
    return nil
  end
end
local function calc_optimal_size(content_size, min, max, gap)
  return math.min(math.abs((max - gap)), math.max(content_size, min))
end
window.center["calc-pos"] = function(max, side, gap)
  return ((max - side - gap) * 0.5)
end
window.center["calc-opts"] = function(args)
  local _let_54_ = psl_win["get-screen-size"]()
  local scr_height = _let_54_[1]
  local scr_width = _let_54_[2]
  local _let_55_ = ut["calc-lines-size"](args.lines)
  local text_height = _let_55_[1]
  local text_width = _let_55_[2]
  local gap = 6
  local width = calc_optimal_size(text_width, args.width, scr_width, (gap + 4))
  local height = calc_optimal_size(text_height, args.height, scr_height, gap)
  return {relative = "editor", width = width, height = height, row = window.center["calc-pos"](scr_height, height, 3), col = window.center["calc-pos"](scr_width, width, 3), title = (" " .. args.title .. " "), title_pos = "center", focusable = not args.nofocusable}
end
window.center.open = function(bufnr, content, config, _3fcallback)
  local lines = ut["text->lines"](content)
  local opts_table = {lines = lines, height = config.height, width = config.width, title = config.title}
  local opts = window.center["calc-opts"](opts_table)
  if not config.noedit then
    buffer["fill!"](bufnr, lines)
  else
  end
  local _57_, _58_ = psl_buf["visible?"](bufnr)
  if ((_57_ == true) and (nil ~= _58_)) then
    local winid = _58_
    window["update-win-options"](winid, opts, true)
    return winid
  elseif true then
    local _ = _57_
    local winid = window["open-float"](bufnr, opts, true, true, _3fcallback)
    vim.api.nvim_win_set_cursor(winid, {1, 0})
    return winid
  else
    return nil
  end
end
return window