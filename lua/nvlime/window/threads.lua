local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local _local_1_ = vim.api
local nvim_create_autocmd = _local_1_["nvim_create_autocmd"]
local threads = {}
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.threads)
local function restrict_cursor(bufnr)
  local prev_col = 1
  local function restrict()
    local linenr = vim.fn.line(".")
    if (linenr < 3) then
      vim.fn.cursor(3, prev_col)
    else
    end
    prev_col = vim.fn.col(".")
    return nil
  end
  local function _3_()
    return restrict()
  end
  return nvim_create_autocmd("CursorMoved", {buffer = bufnr, callback = _3_})
end
local function win_callback(winid, bufnr)
  window["set-opts"](winid, {cursorline = true})
  return restrict_cursor(bufnr)
end
threads.open = function(content, config)
  local bufnr = buffer["create-scratch-with-conn-var!"](buffer["gen-name"](config["conn-name"], buffer.names.threads), _2bfiletype_2b)
  local function _4_(_241, _242)
    return win_callback(_241, _242)
  end
  return {window.center.open(bufnr, content, {height = 10, width = 40, title = buffer.names.threads}, _4_), bufnr}
end
return threads