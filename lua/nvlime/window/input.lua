local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local km = require("nvlime.keymaps")
local ut = require("nvlime.utilities")
local psl_buf = require("parsley.buffer")
local psl_win = require("parsley.window")
local input = {}
local _2bname_2b = "input"
local _2bnamespace_2b = vim.api.nvim_create_namespace(buffer["gen-filetype"](_2bname_2b))
local function calc_opts(config)
  local border_len = 2
  local wininfo = psl_win["get-info"](vim.api.nvim_get_current_win())
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
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  for _, line in ipairs(lines) do
    local val_19_auto = {{line, "Comment"}}
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
local function show_history_extmark(bufnr)
  local extmark_id = 0
  local history_len = #vim.g.nvlime_input_history
  local group = vim.api.nvim_create_augroup("nvlime-input-history", {})
  local add_extmark
  local function _2_()
    vim.api.nvim_buf_clear_namespace(bufnr, _2bnamespace_2b, 0, -1)
    extmark_id = vim.api.nvim_buf_set_extmark(bufnr, _2bnamespace_2b, 0, 0, {virt_lines = text__3evirt_lines(vim.g.nvlime_input_history[history_len])})
    return nil
  end
  add_extmark = _2_
  local function _3_()
    if (psl_buf["empty?"](bufnr) and (history_len > 0)) then
      return add_extmark()
    else
      return vim.api.nvim_buf_clear_namespace(bufnr, _2bnamespace_2b, 0, -1)
    end
  end
  return vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {group = group, buffer = bufnr, callback = _3_})
end
input.open = function(content, config)
  local lines = ut["text->lines"](content)
  local bufnr
  local function _5_(_241)
    return buf_callback(_241)
  end
  bufnr = buffer["create-if-not-exists"](buffer["gen-name"](config["conn-name"], _2bname_2b, config.prompt), false, _5_)
  local opts = calc_opts(config)
  show_history_extmark(bufnr)
  buffer["fill!"](bufnr, lines)
  local winid
  local function _6_()
    return win_callback()
  end
  winid = window["open-float"](bufnr, opts, true, true, _6_)
  return {winid, bufnr}
end
return input