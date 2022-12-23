local window = require("nvlime.window")
local km = require("nvlime.keymaps")
local km_window = require("nvlime.window.keymaps")
local globals = {}
local _2bscroll_step_2b = (vim.g.nvlime_scroll_step or 3)
local _2bscroll_up_2b = (vim.g.nvlime_scroll_up or "<C-p>")
local _2bscroll_down_2b = (vim.g.nvlime_scroll_down or "<C-n>")
local function del_buffer_keymaps(bufnr, mode, maps)
  for _, map in ipairs(maps) do
    pcall(vim.api.nvim_buf_del_keymap, bufnr, mode, map)
  end
  return nil
end
local function split_focus(cmd, key)
  local function _1_()
    if window.split_focus(cmd) then
      return del_buffer_keymaps(0, "n", {"<C-w>h", "<C-w>j", "<C-w>k", "<C-w>l"})
    else
      return nil
    end
  end
  return km.buffer.normal(key, _1_, "Split into last non-floating window")
end
globals.add = function(add_close_3f, add_split_3f)
  if add_close_3f then
    local function _3_()
      return vim.api.nvim_win_close(0, true)
    end
    km.buffer.normal("q", _3_, "Close current window")
  else
  end
  local function _5_()
    return km_window.toggle()
  end
  km.buffer.normal((km.leader .. "?"), _5_, "Show keymaps help")
  local function _6_()
    return km_window.toggle()
  end
  km.buffer.normal("<F1>", _6_, "Show keymaps help")
  local function _7_()
    return window.close_all_except_main()
  end
  km.buffer.normal((km.leader .. "ww"), _7_, "Close all nvlime windows except main ones")
  local function _8_()
    if not window.close_last_float() then
      return km.feedkeys("<Esc>")
    else
      return nil
    end
  end
  km.buffer.normal("<Esc>", _8_, "Close last opened floating window")
  local function _10_()
    if not window.scroll_float(_2bscroll_step_2b, true) then
      return km.feedkeys(_2bscroll_up_2b)
    else
      return nil
    end
  end
  km.buffer.normal(_2bscroll_up_2b, _10_, "Scroll up last opened floating window")
  local function _12_()
    if not window.scroll_float(_2bscroll_step_2b) then
      return km.feedkeys(_2bscroll_down_2b)
    else
      return nil
    end
  end
  km.buffer.normal(_2bscroll_down_2b, _12_, "Scroll down last opened floating window")
  if add_split_3f then
    split_focus("vertical leftabove split", "<C-w>h")
    split_focus("vertical rightbelow split", "<C-w>l")
    split_focus("leftabove split", "<C-w>k")
    return split_focus("rightbelow split", "<C-w>j")
  else
    return nil
  end
end
return globals