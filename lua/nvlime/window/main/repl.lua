local buffer = require("nvlime.buffer")
local main = require("nvlime.window.main")
local ut = require("nvlime.utilities")
local presentations = require("nvlime.contrib.presentations")
local repl = {}
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.repl)
local function repl_banner(conn)
  local data = conn.cb_data
  local banner
  local function _1_()
    if data.version then
      return ("version " .. data.version .. ", ")
    else
      return ""
    end
  end
  local function _2_()
    if data.pid then
      return ("pid " .. data.pid .. ", ")
    else
      return nil
    end
  end
  banner = ("SWANK " .. _1_() .. _2_() .. "remote " .. data.remote_host .. ":" .. data.remote_port)
  local border = string.rep("=", #banner)
  return {banner, border, ""}
end
local function clear_repl_2a(bufnr, conn)
  buffer["set-vars"](bufnr, {nvlime_repl_coords = {}})
  buffer["fill!"](bufnr, repl_banner(conn))
  return vim.api.nvim_buf_clear_namespace(bufnr, presentations.namespace, 0, -1)
end
local function buf_callback(bufnr)
  buffer["set-opts"](bufnr, {filetype = _2bfiletype_2b})
  local conn = buffer["get-conn-var!"](bufnr)
  if conn then
    return clear_repl_2a(bufnr, conn)
  else
    return nil
  end
end
repl.open = function(content, config)
  local lines = ut["text->lines"](content)
  local bufnr
  local function _4_(_241)
    return buf_callback(_241)
  end
  bufnr = buffer["create-if-not-exists"](buffer["gen-repl-name"](config["conn-name"]), false, _4_)
  buffer["append!"](bufnr, lines)
  return {(main.repl):open(bufnr, config["focus?"]), bufnr}
end
repl.clear = function()
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local conn = buffer["get-conn-var!"](cur_bufnr)
  if conn then
    local _let_5_ = repl.open("", {["conn-name"] = conn.cb_data.name})
    local _ = _let_5_[1]
    local bufnr = _let_5_[2]
    clear_repl_2a(bufnr, conn)
    return vim.api.nvim_win_set_cursor(main.repl.id, {3, 0})
  else
    return nil
  end
end
return repl