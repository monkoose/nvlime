local psl_buf = require("parsley.buffer")
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
  return vim.api.nvim_buf_get_option(bufnr, opt)
end
buffer["set-opts"] = function(bufnr, opts)
  for opt, val in pairs(opts) do
    vim.api.nvim_buf_set_option(bufnr, opt, val)
  end
  return nil
end
buffer["set-vars"] = function(bufnr, vars)
  for v, val in pairs(vars) do
    vim.api.nvim_buf_set_var(bufnr, v, val)
  end
  return nil
end
buffer["vim-call!"] = function(bufnr, cmds)
  local function _1_()
    for _, c in ipairs(cmds) do
      vim.api.nvim_exec(c, false)
    end
    return nil
  end
  return vim.api.nvim_buf_call(bufnr, _1_)
end
buffer["set-conn-var!"] = function(bufnr)
  return buffer["vim-call!"](bufnr, {"call nvlime#connection#Get()"})
end
buffer["get-conn-var!"] = function(bufnr)
  buffer["set-conn-var!"](bufnr)
  local _2_, _3_ = pcall(vim.api.nvim_buf_get_var, bufnr, "nvlime_conn")
  if ((_2_ == true) and (nil ~= _3_)) then
    local conn = _3_
    return conn
  else
    return nil
  end
end
buffer.create = function(name, listed_3f, _3fcallback)
  local bufnr = vim.api.nvim_create_buf(listed_3f, false)
  vim.api.nvim_buf_set_name(bufnr, name)
  buffer["set-opts"](bufnr, {buftype = "nofile", modeline = false, modifiable = false, swapfile = false})
  if not listed_3f then
    local function _5_()
      return buffer["set-opts"](bufnr, {buflisted = false})
    end
    vim.api.nvim_create_autocmd("BufWinEnter", {buffer = bufnr, callback = _5_})
    local function _6_()
      return vim.api.nvim_clear_autocmds({event = "BufWinEnter", buffer = bufnr})
    end
    vim.api.nvim_create_autocmd("BufWipeout", {buffer = bufnr, callback = _6_, once = true})
  else
  end
  if _3fcallback then
    _3fcallback(bufnr)
  else
  end
  return bufnr
end
buffer["create-if-not-exists"] = function(name, listed_3f, _3fcallback)
  if psl_buf["exists?"](name) then
    return vim.fn.bufnr(name)
  else
    return buffer.create(name, listed_3f, _3fcallback)
  end
end
buffer["create-listed"] = function(name, filetype)
  local function _10_(_241)
    return buffer["set-opts"](_241, {filetype = filetype})
  end
  return buffer["create-if-not-exists"](name, true, _10_)
end
buffer["create-nolisted"] = function(name, filetype)
  local function _11_(_241)
    return buffer["set-opts"](_241, {filetype = filetype})
  end
  return buffer["create-if-not-exists"](name, false, _11_)
end
buffer["create-scratch"] = function(name, filetype)
  local function _12_(_241)
    return buffer["set-opts"](_241, {filetype = filetype, bufhidden = "wipe"})
  end
  return buffer["create-if-not-exists"](name, false, _12_)
end
buffer["create-scratch-with-conn-var!"] = function(name, filetype)
  local callback
  local function _13_(bufnr)
    buffer["set-conn-var!"](bufnr)
    return buffer["set-opts"](bufnr, {filetype = filetype, bufhidden = "wipe"})
  end
  callback = _13_
  local function _14_(_241)
    return callback(_241)
  end
  return buffer["create-if-not-exists"](name, false, _14_)
end
buffer["fill!"] = function(bufnr, lines, ...)
  local old_mod_2_auto = vim.api.nvim_buf_get_option(bufnr, "modifiable")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  do
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    if ... then
      for _, ls in ipairs({...}) do
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, ls)
      end
    else
    end
  end
  vim.api.nvim_buf_set_option(bufnr, "modifiable", old_mod_2_auto)
  return nil
end
buffer["append!"] = function(bufnr, ...)
  local old_mod_2_auto = vim.api.nvim_buf_get_option(bufnr, "modifiable")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  do
    if ... then
      for _, ls in ipairs({...}) do
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, ls)
      end
    else
    end
  end
  vim.api.nvim_buf_set_option(bufnr, "modifiable", old_mod_2_auto)
  return nil
end
return buffer