local window = require("nvlime.window")
local km = require("nvlime.keymaps")
local gm = km.mappings.global
local km_window = require("nvlime.window.keymaps")
local psl = require("parsley")
local opts = require("nvlime.config")
local _local_1_ = vim.api
local nvim_win_close = _local_1_["nvim_win_close"]
local nvim_buf_del_keymap = _local_1_["nvim_buf_del_keymap"]
local globals = {}
local function del_buffer_keymaps(bufnr, mode, maps)
  for _, map in ipairs(maps) do
    pcall(nvim_buf_del_keymap, bufnr, mode, map)
  end
  return nil
end
local split_keys = {}
for _, keys in ipairs({gm.normal.slit_left, gm.normal.split_right, gm.normal.split_above, gm.normal.split_below}) do
  if psl["string?"](keys) then
    table.insert(split_keys, keys)
  else
    local tbl_17_auto = split_keys
    for _0, key in ipairs(keys) do
      local val_18_auto = key
      table.insert(tbl_17_auto, val_18_auto)
    end
  end
end
local function split_focus(cmd, key)
  local function _3_()
    if window.split_focus(cmd) then
      return del_buffer_keymaps(0, "n", split_keys)
    else
      return nil
    end
  end
  return km.buffer.normal(key, _3_, "Split into last non-floating window")
end
globals.add = function(add_close_3f, add_split_3f)
  if add_close_3f then
    local function _5_()
      return nvim_win_close(0, true)
    end
    km.buffer.normal(gm.normal.close_current_window, _5_, "Close current window")
  else
  end
  local function _7_()
    return km_window.toggle()
  end
  km.buffer.normal(gm.normal.keymaps_help, _7_, "Show keymaps help")
  local function _8_()
    return window.close_all_except_main()
  end
  km.buffer.normal(gm.normal.close_nvlime_windows, _8_, "Close all nvlime windows except main ones")
  local function _9_(_241)
    if not window.close_last_float() then
      return _241()
    else
      return nil
    end
  end
  km.buffer.normal(gm.normal.close_floating_window, _9_, "Close last opened floating window")
  local function _11_(_241)
    if not window.scroll_float(opts.floating_window.scroll_step, true) then
      return _241()
    else
      return nil
    end
  end
  km.buffer.normal(gm.normal.scroll_up, _11_, "Scroll up last opened floating window")
  local function _13_(_241)
    if not window.scroll_float(opts.floating_window.scroll_step) then
      return _241()
    else
      return nil
    end
  end
  km.buffer.normal(gm.normal.scroll_down, _13_, "Scroll down last opened floating window")
  if add_split_3f then
    split_focus("vertical leftabove split", gm.normal.split_left)
    split_focus("vertical rightbelow split", gm.normal.split_right)
    split_focus("leftabove split", gm.normal.split_above)
    return split_focus("rightbelow split", gm.normal.split_below)
  else
    return nil
  end
end
return globals