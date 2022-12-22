local window = require("nvlime.window")
local psl_win = require("parsley.window")
local main_win_pos
do
  local _1_
  do
    local t_2_ = vim.g
    if (nil ~= t_2_) then
      t_2_ = (t_2_).nvlime_main_win
    else
    end
    if (nil ~= t_2_) then
      t_2_ = (t_2_).pos
    else
    end
    _1_ = t_2_
  end
  if (_1_ == "top") then
    main_win_pos = "topleft"
  elseif (_1_ == "left") then
    main_win_pos = "vertical topleft"
  elseif (_1_ == "bottom") then
    main_win_pos = "botright"
  elseif (_1_ == "right") then
    main_win_pos = "vertical botright"
  elseif true then
    local _ = _1_
    main_win_pos = "vertical botright"
  else
    main_win_pos = nil
  end
end
local main_win
local function _6_(...)
  local t_7_ = vim.g
  if (nil ~= t_7_) then
    t_7_ = (t_7_).nvlime_main_win
  else
  end
  if (nil ~= t_7_) then
    t_7_ = (t_7_).size
  else
  end
  return t_7_
end
main_win = {pos = main_win_pos, size = (_6_(...) or ""), ["vert?"] = (nil ~= (main_win_pos and string.find(main_win_pos, "^vertical")))}
main_win.new = function(cmd, size, opposite)
  local self = setmetatable({}, {__index = main_win})
  local vert_3f = main_win["vert?"]
  self["id"] = nil
  self["buffers"] = {}
  local _10_
  if vert_3f then
    _10_ = cmd
  else
    _10_ = ("vertical " .. cmd)
  end
  self["cmd"] = _10_
  local _12_
  if vert_3f then
    _12_ = size
  else
    _12_ = nil
  end
  self["size"] = _12_
  self["opposite"] = opposite
  return self
end
do
  local sldb_height = 0.65
  main_win["sldb"] = main_win.new("", sldb_height, "repl")
  do end (main_win)["repl"] = main_win.new("leftabove", (1 - sldb_height), "sldb")
end
main_win["set-id"] = function(self, winid)
  self["id"] = winid
  return nil
end
main_win["set-options"] = function(self)
  window["set-minimal-style-options"](self.id)
  vim.api.nvim_win_set_option(self.id, "foldcolumn", "1")
  return vim.api.nvim_win_set_option(self.id, "winhighlight", "FoldColumn:Normal")
end
main_win["remove-buf"] = function(self, bufnr)
  for i, b in ipairs(self.buffers) do
    if (b == bufnr) then
      table.remove(self.buffers, i)
    else
    end
  end
  return nil
end
main_win["add-buf"] = function(self, bufnr)
  self["remove-buf"](self, bufnr)
  return table.insert(self.buffers, bufnr)
end
main_win["update-opts"] = function(self)
  local winid = vim.api.nvim_get_current_win()
  self["set-id"](self, winid)
  self["add-buf"](self, vim.api.nvim_win_get_buf(winid))
  return self["set-options"](self)
end
main_win["split-opposite"] = function(self, bufnr)
  local opposite = main_win[self.opposite]
  vim.api.nvim_set_current_win(opposite.id)
  local height
  if self.size then
    height = math.floor((psl_win["get-height"](opposite.id) * self.size))
  else
    height = ""
  end
  vim.api.nvim_exec((self.cmd .. " " .. height .. "split " .. vim.api.nvim_buf_get_name(bufnr)), false)
  return self["update-opts"](self)
end
main_win.split = function(self, bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  vim.api.nvim_exec((main_win.pos .. " " .. main_win.size .. "split " .. bufname), false)
  return self["update-opts"](self)
end
main_win["open-new"] = function(self, bufnr, focus_3f)
  local prev_winid = vim.api.nvim_get_current_win()
  local opposite = main_win[self.opposite]
  if psl_win["visible?"](opposite.id) then
    self["split-opposite"](self, bufnr)
  else
    self:split(bufnr)
  end
  if not focus_3f then
    return vim.api.nvim_set_current_win(prev_winid)
  else
    return nil
  end
end
main_win["show-buf"] = function(self, bufnr, focus_3f)
  if (vim.api.nvim_win_get_buf(self.id) ~= bufnr) then
    vim.api.nvim_win_set_buf(self.id, bufnr)
    self["add-buf"](self, bufnr)
  else
  end
  if focus_3f then
    return vim.api.nvim_set_current_win(self.id)
  else
    return nil
  end
end
main_win.open = function(self, bufnr, focus_3f)
  if psl_win["visible?"](self.id) then
    self["show-buf"](self, bufnr, focus_3f)
  else
    self["open-new"](self, bufnr, focus_3f)
  end
  return self.id
end
return main_win