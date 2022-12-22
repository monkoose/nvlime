local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local threads = {}
local _2bname_2b = "threads"
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
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
  local function _2_()
    return restrict()
  end
  return vim.api.nvim_create_autocmd("CursorMoved", {buffer = bufnr, callback = _2_})
end
local function win_callback(winid, bufnr)
  window["set-opts"](winid, {cursorline = true})
  return restrict_cursor(bufnr)
end
threads.open = function(content, config)
  local bufnr = buffer["create-scratch-with-conn-var!"](buffer["gen-name"](config["conn-name"], _2bname_2b), _2bfiletype_2b)
  local function _3_(_241, _242)
    return win_callback(_241, _242)
  end
  return {window.center.open(bufnr, content, {height = 10, width = 40, title = _2bname_2b}, _3_), bufnr}
end
return threads