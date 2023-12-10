local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local km = require("nvlime.keymaps")
local ut = require("nvlime.utilities")
local psl_buf = require("parsley.buffer")
local psl_win = require("parsley.window")
local _local_1_ = vim.api
local nvim_create_namespace = _local_1_["nvim_create_namespace"]
local nvim_create_augroup = _local_1_["nvim_create_augroup"]
local nvim_create_autocmd = _local_1_["nvim_create_autocmd"]
local nvim_buf_clear_namespace = _local_1_["nvim_buf_clear_namespace"]
local nvim_buf_set_extmark = _local_1_["nvim_buf_set_extmark"]
local nvim_get_current_win = _local_1_["nvim_get_current_win"]
local input = {}
local _2bnamespace_2b = nvim_create_namespace(buffer["gen-filetype"](buffer.names.input))
local function calc_opts(config)
  local border_len = 2
  local wininfo = psl_win["get-info"](nvim_get_current_win())
  local width = math.min(80, (wininfo.width - wininfo.textoff - border_len))
  local height = 4
  local row = (wininfo.height - height - border_len)
  return {relative = "win", row = row, col = wininfo.textoff, width = width, height = height, title = config.prompt, title_pos = "center"}
end
local function buf_callback(bufnr)
  buffer["set-conn-var!"](bufnr)
  buffer["set-vars"](bufnr, {nvlime_input = true})
  return buffer["set-opts"](bufnr, {filetype = "lisp", bufhidden = "wipe", modifiable = true})
end
local function win_callback()
  return km.feedkeys("a")
end
local function text__3evirt_lines(str)
  local lines = ut["text->lines"](str)
  local tbl_18_auto = {}
  local i_19_auto = 0
  for _, line in ipairs(lines) do
    local val_20_auto = {{line, "Comment"}}
    if (nil ~= val_20_auto) then
      i_19_auto = (i_19_auto + 1)
      do end (tbl_18_auto)[i_19_auto] = val_20_auto
    else
    end
  end
  return tbl_18_auto
end
local function show_history_extmark(bufnr)
  local extmark_id = 0
  local history_len = #vim.g.nvlime_input_history
  local group = nvim_create_augroup("nvlime-input-history", {})
  local add_extmark
  local function _3_()
    nvim_buf_clear_namespace(bufnr, _2bnamespace_2b, 0, -1)
    extmark_id = nvim_buf_set_extmark(bufnr, _2bnamespace_2b, 0, 0, {virt_lines = text__3evirt_lines(vim.g.nvlime_input_history[history_len])})
    return nil
  end
  add_extmark = _3_
  local function _4_()
    if (psl_buf["empty?"](bufnr) and (history_len > 0)) then
      return add_extmark()
    else
      return nvim_buf_clear_namespace(bufnr, _2bnamespace_2b, 0, -1)
    end
  end
  return nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {group = group, buffer = bufnr, callback = _4_})
end
input.open = function(content, config)
  local lines = ut["text->lines"](content)
  local bufnr
  local function _6_(_241)
    return buf_callback(_241)
  end
  bufnr = buffer["create-if-not-exists"](buffer["gen-name"](config["conn-name"], buffer.names.input, config.prompt), false, _6_)
  local opts = calc_opts(config)
  show_history_extmark(bufnr)
  buffer["fill!"](bufnr, lines)
  local winid
  local function _7_()
    return win_callback()
  end
  winid = window["open-float"](bufnr, opts, true, true, _7_)
  return {winid, bufnr}
end
return input