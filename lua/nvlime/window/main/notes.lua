local buffer = require("nvlime.buffer")
local sldb = require("nvlime.window.main").sldb
local psl = require("parsley")
local _local_1_ = vim.api
local nvim_create_autocmd = _local_1_["nvim_create_autocmd"]
local nvim_win_get_buf = _local_1_["nvim_win_get_buf"]
local nvim_create_augroup = _local_1_["nvim_create_augroup"]
local notes = {}
local _2bname_2b = "notes"
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
local function remove_notes(bufnr)
  sldb["remove-buf"](sldb, bufnr)
  if ((nvim_win_get_buf(sldb.id) == bufnr) and not psl["empty?"](sldb.buffers)) then
    local function _2_()
      return sldb["open-new"](sldb, sldb.buffers[#sldb.buffers], true)
    end
    return vim.defer_fn(_2_, 0)
  else
    return nil
  end
end
local function win_callback(winid, bufnr)
  local group = nvim_create_augroup(_2bfiletype_2b, {})
  local function _4_()
    return remove_notes(bufnr)
  end
  return nvim_create_autocmd("WinClosed", {group = group, pattern = tostring(winid), nested = true, callback = _4_})
end
notes.open = function(config)
  local bufnr = buffer["create-nolisted"](buffer["gen-name"](config["conn-name"], ("compiler-" .. _2bname_2b)), _2bfiletype_2b)
  local winid = sldb:open(bufnr, true)
  win_callback(winid, bufnr)
  return {winid, bufnr}
end
return notes