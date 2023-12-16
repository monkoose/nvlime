local buffer = require("nvlime.buffer")
local main = require("nvlime.window.main")
local psl = require("parsley")
local pbuf = require("parsley.buffer")
local _local_1_ = vim.api
local nvim_win_set_buf = _local_1_["nvim_win_set_buf"]
local nvim_win_close = _local_1_["nvim_win_close"]
local nvim_buf_get_var = _local_1_["nvim_buf_get_var"]
local sldb = {}
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.sldb)
local function buf_callback(bufnr, opts)
  buffer["set-opts"](bufnr, {filetype = _2bfiletype_2b})
  buffer["set-vars"](bufnr, {nvlime_sldb_level = opts.level, nvlime_sldb_frames = opts.frames})
  buffer["set-conn-var!"](bufnr)
  return buffer["vim-call!"](bufnr, {("call b:nvlime_conn.SetCurrentThread(" .. opts.thread .. ")")})
end
sldb["on-debug-return"] = function(config)
  local exists_3f, bufnr = pbuf["exists?"](buffer["gen-sldb-name"](config["conn-name"], config.thread))
  if exists_3f then
    local buf_level = (nvim_buf_get_var(bufnr, "nvlime_sldb_level") or -1)
    if (buf_level == config.level) then
      do end (function(tgt, m, ...) return tgt[m](tgt, ...) end)(main.sldb, "remove-buf", bufnr)
      buffer["fill!"](bufnr, {})
      buffer["set-vars"](bufnr, {buflisted = false})
      if not psl["empty?"](main.sldb.buffers) then
        return nvim_win_set_buf(main.sldb.id, main.sldb.buffers[#main.sldb.buffers])
      else
        return nvim_win_close(main.sldb.id, true)
      end
    else
      return nil
    end
  else
    return nil
  end
end
sldb.open = function(content, config)
  local bufnr
  local function _5_(_241)
    return buf_callback(_241, config)
  end
  bufnr = buffer["create-if-not-exists"](buffer["gen-sldb-name"](config["conn-name"], config.thread), true, _5_)
  return {(main.sldb):open(bufnr, true), bufnr}
end
return sldb