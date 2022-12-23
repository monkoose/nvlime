local buffer = require("nvlime.buffer")
local main = require("nvlime.window.main")
local psl = require("parsley")
local psl_buf = require("parsley.buffer")
local sldb = {}
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.sldb)
local function buf_callback(bufnr, opts)
  buffer["set-opts"](bufnr, {filetype = _2bfiletype_2b})
  buffer["set-vars"](bufnr, {nvlime_sldb_level = opts.level, nvlime_sldb_frames = opts.frames})
  buffer["set-conn-var!"](bufnr)
  return buffer["vim-call!"](bufnr, {("call b:nvlime_conn.SetCurrentThread(" .. opts.thread .. ")")})
end
sldb["on-debug-return"] = function(config)
  local _1_, _2_ = psl_buf["exists?"](buffer["gen-sldb-name"](config["conn-name"], config.thread))
  if ((_1_ == true) and (nil ~= _2_)) then
    local bufnr = _2_
    local buf_level = (vim.api.nvim_buf_get_var(bufnr, "nvlime_sldb_level") or -1)
    if (buf_level == config.level) then
      do end (function(tgt, m, ...) return tgt[m](tgt, ...) end)(main.sldb, "remove-buf", bufnr)
      buffer["fill!"](bufnr, {})
      buffer["set-vars"](bufnr, {buflisted = false})
      if not psl["empty?"](main.sldb.buffers) then
        return vim.api.nvim_win_set_buf(main.sldb.id, main.sldb.buffers[#main.sldb.buffers])
      else
        return vim.api.nvim_win_close(main.sldb.id, true)
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
  local function _6_(_241)
    return buf_callback(_241, config)
  end
  bufnr = buffer["create-if-not-exists"](buffer["gen-sldb-name"](config["conn-name"], config.thread), true, _6_)
  return {(main.sldb):open(bufnr, true), bufnr}
end
return sldb