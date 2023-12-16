local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local ut = require("nvlime.utilities")
local pbuf = require("parsley.buffer")
local pwin = require("parsley.window")
local _local_1_ = vim.api
local nvim_create_autocmd = _local_1_["nvim_create_autocmd"]
local nvim_get_current_win = _local_1_["nvim_get_current_win"]
local arglist = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.arglist)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.arglist)
local function calc_opts(args)
  local border_len = 2
  local wininfo = pwin["get-info"](nvim_get_current_win())
  local width = (wininfo.width - wininfo.textoff - border_len)
  local height = math.min(4, #args.lines)
  local curline = vim.fn.line(".")
  local row
  if ((curline - wininfo.topline) > ((wininfo.topline + wininfo.height) - curline)) then
    row = wininfo.winbar
  else
    row = (wininfo.height - height - border_len)
  end
  return {relative = "win", row = row, col = wininfo.textoff, width = width, height = height, focusable = false}
end
local function win_callback(winid)
  window["set-opt"](winid, "conceallevel", 2)
  local function _3_()
    return window["close-float"](winid)
  end
  return nvim_create_autocmd("InsertLeave", {callback = _3_, once = true})
end
arglist.show = function(content)
  local lines = ut["text->lines"](content)
  local bufnr = buffer["create-nolisted"](_2bbufname_2b, _2bfiletype_2b)
  local opts = calc_opts({lines = lines})
  buffer["fill!"](bufnr, lines)
  local _4_, _5_ = pbuf["visible?"](bufnr)
  if ((_4_ == true) and (nil ~= _5_)) then
    local winid = _5_
    window["update-win-options"](winid, opts)
    return {winid, bufnr}
  else
    local _ = _4_
    local function _6_(_241)
      return win_callback(_241)
    end
    return {window["open-float"](bufnr, opts, false, false, _6_), bufnr}
  end
end
return arglist