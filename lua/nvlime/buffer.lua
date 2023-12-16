local pbuf = require("parsley.buffer")
local _local_1_ = vim.api
local nvim_create_autocmd = _local_1_["nvim_create_autocmd"]
local nvim_buf_call = _local_1_["nvim_buf_call"]
local nvim_buf_get_option = _local_1_["nvim_buf_get_option"]
local nvim_buf_set_name = _local_1_["nvim_buf_set_name"]
local nvim_buf_set_var = _local_1_["nvim_buf_set_var"]
local nvim_buf_set_option = _local_1_["nvim_buf_set_option"]
local nvim_clear_autocmds = _local_1_["nvim_clear_autocmds"]
local nvim_create_buf = _local_1_["nvim_create_buf"]
local nvim_buf_set_lines = _local_1_["nvim_buf_set_lines"]
local nvim_buf_get_var = _local_1_["nvim_buf_get_var"]
local nvim_exec = _local_1_["nvim_exec"]
local buffer = {}
buffer["names"] = {repl = "repl", sldb = "sldb", xref = "xref", input = "input", notes = "notes", trace = "trace", server = "server", apropos = "apropos", arglist = "arglist", keymaps = "keymaps", threads = "threads", inspector = "inspector", description = "description", disassembly = "disassembly", macroexpand = "macroexpand", documentation = "documentation"}
buffer["gen-name"] = function(...)
  return ("nvlime://" .. table.concat({...}, "/"))
end
buffer["gen-repl-name"] = function(conn_name)
  return buffer["gen-name"](conn_name, buffer.names.repl)
end
buffer["gen-sldb-name"] = function(conn_name, thread)
  return buffer["gen-name"](conn_name, buffer.names.sldb, thread)
end
buffer["gen-filetype"] = function(suffix)
  return ("nvlime_" .. suffix)
end
buffer["get-opt"] = function(bufnr, opt)
  return nvim_buf_get_option(bufnr, opt)
end
buffer["set-opts"] = function(bufnr, opts)
  for opt, val in pairs(opts) do
    nvim_buf_set_option(bufnr, opt, val)
  end
  return nil
end
buffer["set-vars"] = function(bufnr, vars)
  for v, val in pairs(vars) do
    nvim_buf_set_var(bufnr, v, val)
  end
  return nil
end
buffer["vim-call!"] = function(bufnr, cmds)
  local function _2_()
    for _, c in ipairs(cmds) do
      nvim_exec(c, false)
    end
    return nil
  end
  return nvim_buf_call(bufnr, _2_)
end
buffer["set-conn-var!"] = function(bufnr)
  return buffer["vim-call!"](bufnr, {"call nvlime#connection#Get()"})
end
buffer["get-conn-var!"] = function(bufnr)
  buffer["set-conn-var!"](bufnr)
  local _3_, _4_ = pcall(nvim_buf_get_var, bufnr, "nvlime_conn")
  if ((_3_ == true) and (nil ~= _4_)) then
    local conn = _4_
    return conn
  else
    return nil
  end
end
buffer.create = function(name, listed_3f, callback)
  local bufnr = nvim_create_buf(listed_3f, false)
  nvim_buf_set_name(bufnr, name)
  buffer["set-opts"](bufnr, {buftype = "nofile", modeline = false, modifiable = false, swapfile = false})
  if not listed_3f then
    local function _6_()
      return buffer["set-opts"](bufnr, {buflisted = false})
    end
    nvim_create_autocmd("BufWinEnter", {buffer = bufnr, callback = _6_})
    local function _7_()
      return nvim_clear_autocmds({event = "BufWinEnter", buffer = bufnr})
    end
    nvim_create_autocmd("BufWipeout", {buffer = bufnr, callback = _7_, once = true})
  else
  end
  if callback then
    callback(bufnr)
  else
  end
  return bufnr
end
buffer["create-if-not-exists"] = function(name, listed_3f, callback)
  if pbuf["exists?"](name) then
    return vim.fn.bufnr(name)
  else
    return buffer.create(name, listed_3f, callback)
  end
end
buffer["create-listed"] = function(name, filetype)
  local function _11_(_241)
    return buffer["set-opts"](_241, {filetype = filetype})
  end
  return buffer["create-if-not-exists"](name, true, _11_)
end
buffer["create-nolisted"] = function(name, filetype)
  local function _12_(_241)
    return buffer["set-opts"](_241, {filetype = filetype})
  end
  return buffer["create-if-not-exists"](name, false, _12_)
end
buffer["create-scratch"] = function(name, filetype)
  local function _13_(_241)
    return buffer["set-opts"](_241, {filetype = filetype, bufhidden = "wipe"})
  end
  return buffer["create-if-not-exists"](name, false, _13_)
end
buffer["create-scratch-with-conn-var!"] = function(name, filetype)
  local callback
  local function _14_(bufnr)
    buffer["set-conn-var!"](bufnr)
    return buffer["set-opts"](bufnr, {filetype = filetype, bufhidden = "wipe"})
  end
  callback = _14_
  local function _15_(_241)
    return callback(_241)
  end
  return buffer["create-if-not-exists"](name, false, _15_)
end
buffer["fill!"] = function(bufnr, lines, ...)
  local old_mod_2_auto = nvim_buf_get_option(bufnr, "modifiable")
  nvim_buf_set_option(bufnr, "modifiable", true)
  do
    nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    if ... then
      for _, ls in ipairs({...}) do
        nvim_buf_set_lines(bufnr, -1, -1, false, ls)
      end
    else
    end
  end
  nvim_buf_set_option(bufnr, "modifiable", old_mod_2_auto)
  return nil
end
buffer["append!"] = function(bufnr, ...)
  local old_mod_2_auto = nvim_buf_get_option(bufnr, "modifiable")
  nvim_buf_set_option(bufnr, "modifiable", true)
  do
    if ... then
      for _, ls in ipairs({...}) do
        nvim_buf_set_lines(bufnr, -1, -1, false, ls)
      end
    else
    end
  end
  nvim_buf_set_option(bufnr, "modifiable", old_mod_2_auto)
  return nil
end
return buffer