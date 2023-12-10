local km = require("nvlime.keymaps")
local buffer = require("nvlime.buffer")
local window = require("nvlime.window")
local ut = require("nvlime.utilities")
local psl_buf = require("parsley.buffer")
local psl_win = require("parsley.window")
local keymaps = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.keymaps)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.keymaps)
local function format_keymap_line(mode, map, desc)
  return string.format("%-5s %-10s %s", mode, map, desc)
end
local function cursor_overlap_3f(width, col, scr_col)
  local border_len = 2
  if ((scr_col >= col) and (scr_col <= (col + width + border_len))) then
    return true
  else
    return nil
  end
end
local function calc_keymaps_opts(args)
  local _let_2_ = psl_win["get-screen-size"]()
  local scr_height = _let_2_[1]
  local scr_width = _let_2_[2]
  local _let_3_ = ut["calc-lines-size"](args.lines)
  local text_height = _let_3_[1]
  local text_width = _let_3_[2]
  local width = math.min((scr_width - 4), text_width)
  local center_col = window.center["calc-pos"](scr_width, width, 3)
  local _let_4_ = psl_win["get-screen-pos"]()
  local scr_row = _let_4_[1]
  local scr_col = _let_4_[2]
  local title = " nvlime buffer keymaps "
  if cursor_overlap_3f(width, center_col, scr_col) then
    local bot_3f, height = window["find-horiz-pos"](text_height, scr_row, scr_height)
    local row
    if bot_3f then
      row = 1
    else
      row = ( - (height + 2))
    end
    local col = (center_col - scr_col)
    return {relative = "cursor", row = row, col = col, width = width, height = height, title = title, title_pos = "center", focusable = false}
  else
    return window.center["calc-opts"]({lines = args.lines, width = 1, height = 1, title = title, title_pos = "center", nofocusable = true})
  end
end
local function win_callback(winid)
  window.cursor.callback(winid)
  local function _7_()
    return window["close-float"](winid)
  end
  return vim.api.nvim_create_autocmd("WinLeave", {callback = _7_, once = true})
end
local function open_keymaps_win(bufnr)
  local lines = {format_keymap_line("MODE", "MAP", "DESCRIPTION")}
  do
    local tbl_17_auto = lines
    for _, map in ipairs(km.buffer.get()) do
      table.insert(tbl_17_auto, format_keymap_line(map.mode, map.lhs, map.desc))
    end
  end
  if (#lines > 1) then
    buffer["fill!"](bufnr, lines)
    local function _8_(_241)
      return win_callback(_241)
    end
    return window["open-float"](bufnr, calc_keymaps_opts({lines = lines}), true, false, _8_)
  else
    return nil
  end
end
keymaps.toggle = function()
  local bufnr = buffer["create-scratch"](_2bbufname_2b, _2bfiletype_2b)
  local _10_, _11_ = psl_buf["visible?"](bufnr)
  if ((_10_ == true) and (nil ~= _11_)) then
    local winid = _11_
    window["close-float"](winid)
    return {winid, bufnr}
  else
    local _ = _10_
    return {open_keymaps_win(bufnr), bufnr}
  end
end
return keymaps